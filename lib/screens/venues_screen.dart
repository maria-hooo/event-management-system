import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../services/venue_repo.dart';
import '../widgets/busy_overlay.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final repo = VenueRepo();
  bool busy = false;
  List<Venue> items = [];
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

  Future<void> _openForm({Venue? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final capCtrl = TextEditingController(text: (existing?.capacityLimit ?? 0).toString());
    final locCtrl = TextEditingController(text: jsonEncode(existing?.locationJson ?? {'lat': 0, 'lng': 0}));

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Venue' : 'Edit Venue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity limit')),
              TextField(controller: locCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'locationJson (JSON)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true) return;

    Map<String, dynamic> loc = {'lat': 0, 'lng': 0};
    try {
      loc = jsonDecode(locCtrl.text) as Map<String, dynamic>;
    } catch (_) {}

    setState(() => busy = true);
    try {
      final cap = int.tryParse(capCtrl.text) ?? 0;
      if (existing == null) {
        await repo.create(
          name: nameCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          capacityLimit: cap,
          locationJson: loc,
        );
      } else {
        await repo.update(
          id: existing.id,
          name: nameCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          capacityLimit: cap,
          locationJson: loc,
        );
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
        appBar: AppBar(title: const Text('Venues'), actions: [
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
                  final v = items[i];
                  return ListTile(
                    title: Text(v.name),
                    subtitle: Text('${v.address}\nLimit: ${v.capacityLimit}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(existing: v),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
