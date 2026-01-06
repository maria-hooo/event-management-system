import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/organizer.dart';
import '../services/events_api.dart';
import '../services/organizers_api.dart';
import '../services/api_client.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  Future<List<EventModel>> _loadEvents() => EventsApi.fetchAll();
  Future<List<Organizer>> _loadOrganizers() => OrganizersApi.fetchAll();

  static const _categories = <String>["music", "sports", "tech", "art", "business"];

  String _prettyCategory(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return raw;
    return t[0].toUpperCase() + t.substring(1);
  }

  String _formatDateOnly(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatEventDateTime(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final loc = MaterialLocalizations.of(context);

    final dateStr = loc.formatMediumDate(local);
    final timeStr = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: false,
    );

    return '$dateStr • $timeStr';
  }

  Future<void> _openEditor({EventModel? existing}) async {
    final organizers = await _loadOrganizers();
    if (!mounted) return;

    Organizer? selectedOrganizer;
    if (existing != null) {
      selectedOrganizer = organizers.firstWhere(
        (o) => o.id == existing.organizer.id,
        orElse: () => organizers.isNotEmpty
            ? organizers.first
            : Organizer(id: existing.organizer.id, name: existing.organizer.name),
      );
    } else {
      selectedOrganizer = organizers.isNotEmpty ? organizers.first : null;
    }

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    String category = existing?.category ?? _categories.first;

    final maxAttCtrl = TextEditingController(
      text: (existing?.maxAttendees ?? 100).toString(),
    );

    DateTime selectedDate = (existing?.startDate ?? DateTime.now().add(const Duration(days: 7))).toLocal();
    final startDateCtrl = TextEditingController(text: _formatDateOnly(selectedDate));

    bool isPublic = existing?.isPublic ?? true;

    final tagsCtrl = TextEditingController(text: (existing?.tags ?? []).join(', '));
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    final priceCtrl = TextEditingController(text: (existing?.price ?? 0).toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setLocal(() {
                selectedDate = picked;
                startDateCtrl.text = _formatDateOnly(selectedDate);
              });
            }

            return AlertDialog(
              title: Text(existing == null ? 'Create a new event' : 'Edit event'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (organizers.isEmpty)
                      const Text('No organizers found. Please create an organizer first.')
                    else
                      DropdownButtonFormField<String>(
                        value: selectedOrganizer?.id,
                        decoration: const InputDecoration(labelText: 'Organizer'),
                        items: organizers
                            .map((o) => DropdownMenuItem(value: o.id, child: Text(o.name)))
                            .toList(),
                        onChanged: (v) {
                          setLocal(() {
                            selectedOrganizer = organizers.firstWhere((o) => o.id == v);
                          });
                        },
                      ),

                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Event title'),
                    ),

                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(_prettyCategory(c))))
                          .toList(),
                      onChanged: (v) => setLocal(() => category = v ?? category),
                    ),

                    TextField(
                      controller: maxAttCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Maximum attendees'),
                    ),

                    TextField(
                      controller: startDateCtrl,
                      readOnly: true,
                      onTap: pickDate,
                      decoration: InputDecoration(
                        labelText: 'Event date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: pickDate,
                        ),
                      ),
                    ),

                    SwitchListTile(
                      value: isPublic,
                      onChanged: (v) => setLocal(() => isPublic = v),
                      title: const Text('Make this event public'),
                    ),

                    TextField(
                      controller: tagsCtrl,
                      decoration: const InputDecoration(labelText: 'Tags'),
                    ),

                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),

                    TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(labelText: 'Event image link'),
                    ),

                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: organizers.isEmpty ? null : () => Navigator.pop(ctx, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    if (selectedOrganizer == null) return;

    final body = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'category': category,
      'maxAttendees': int.tryParse(maxAttCtrl.text.trim()) ?? 0,

      // Send date-only format yyyy-MM-dd
      'startDate': startDateCtrl.text.trim(),

      'isPublic': isPublic,
      'tags': tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'extra': {
        'location': locationCtrl.text.trim(),
        'imageUrl': imageCtrl.text.trim(),
      },
      'organizerId': selectedOrganizer?.id,
      'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
    };

    try {
      if (existing == null) {
        await EventsApi.createEvent(body);
      } else {
        await EventsApi.updateEvent(existing.id, body);
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _delete(EventModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event'),
        content: Text('Are you sure you want to delete "${e.displayTitle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiClient.deleteJson(ApiClient.uri('/events/${e.id}'));
      if (mounted) setState(() {});
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage events')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _loadEvents(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Something went wrong: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No events yet. Tap the plus button to create your first event.'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];

              final subtitle = [
                _prettyCategory(e.category),
                _formatEventDateTime(context, e.startDate),
                e.organizer.name,
              ].where((s) => s.trim().isNotEmpty).join(' • ');

              return ListTile(
                title: Text(e.displayTitle),
                subtitle: Text(subtitle),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit event',
                      onPressed: () => _openEditor(existing: e),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete event',
                      onPressed: () => _delete(e),
                    ),
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
