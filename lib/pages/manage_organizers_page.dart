import 'package:flutter/material.dart';

import '../models/organizer.dart';
import '../services/organizers_api.dart';

class ManageOrganizersPage extends StatefulWidget {
  const ManageOrganizersPage({super.key});

  @override
  State<ManageOrganizersPage> createState() => _ManageOrganizersPageState();
}

class _ManageOrganizersPageState extends State<ManageOrganizersPage> {
  Future<List<Organizer>> _load() => OrganizersApi.fetchAll();

  Future<void> _openEditor({Organizer? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'Create Organizer' : 'Edit Organizer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        );
      },
    );

    if (ok != true) return;

    final body = {
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
    }..removeWhere((k, v) => v == null);

    try {
      if (existing == null) {
        await OrganizersApi.create(body);
      } else {
        await OrganizersApi.update(existing.id, body);
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _delete(Organizer o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Organizer'),
        content: Text('Delete "${o.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await OrganizersApi.delete(o.id);
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Organizers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Organizer>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No organizers yet. Tap + to create one.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = items[i];
              return ListTile(
                title: Text(o.name),
                subtitle: Text([o.email, o.phone].where((e) => e != null && e!.isNotEmpty).map((e) => e!).join(' • ')),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditor(existing: o)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(o)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
