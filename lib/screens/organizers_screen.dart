import 'package:flutter/material.dart';
import '../models/organizer.dart';
import '../services/organizer_repo.dart';
import '../widgets/busy_overlay.dart';

class OrganizersScreen extends StatefulWidget {
  const OrganizersScreen({super.key});

  @override
  State<OrganizersScreen> createState() => _OrganizersScreenState();
}

class _OrganizersScreenState extends State<OrganizersScreen> {
  final repo = OrganizerRepo();
  bool busy = false;
  List<Organizer> items = [];
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      busy = true;
      err = null;
    });
    try {
      final data = await repo.list();
      setState(() => items = data);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _openForm({Organizer? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.orgName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Organizer' : 'Edit Organizer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Org name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true) return;

    setState(() => busy = true);
    try {
      if (existing == null) {
        await repo.create(nameCtrl.text.trim(), phoneCtrl.text.trim());
      } else {
        await repo.update(existing.id, nameCtrl.text.trim(), phoneCtrl.text.trim());
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BusyOverlay(
      busy: busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Organizers'), actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openForm(),
          child: const Icon(Icons.add),
        ),
        body: err != null
            ? Center(child: Text(err!))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final o = items[i];
                  return ListTile(
                    title: Text(o.orgName),
                    subtitle: Text(o.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(existing: o),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
