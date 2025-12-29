import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/organizer.dart';
import '../models/venue.dart';
import '../services/event_repo.dart';
import '../services/organizer_repo.dart';
import '../services/venue_repo.dart';
import '../widgets/busy_overlay.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final repo = EventRepo();
  final orgRepo = OrganizerRepo();
  final venueRepo = VenueRepo();

  bool busy = false;
  String? err;

  List<EventItem> items = [];
  List<Organizer> organizers = [];
  List<Venue> venues = [];

  String eventTypeFilter = '';
  bool? isPublicFilter;

  final types = const ['conference', 'workshop', 'concert', 'meetup'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      busy = true;
      err = null;
    });
    try {
      final orgs = await orgRepo.list();
      final vens = await venueRepo.list();
      final evs = await repo.list(
        eventType: eventTypeFilter.isEmpty ? null : eventTypeFilter,
        isPublic: isPublicFilter,
      );
      setState(() {
        organizers = orgs;
        venues = vens;
        items = evs;
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      busy = true;
      err = null;
    });
    try {
      final evs = await repo.list(
        eventType: eventTypeFilter.isEmpty ? null : eventTypeFilter,
        isPublic: isPublicFilter,
      );
      setState(() => items = evs);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _openForm({EventItem? existing}) async {
    if (organizers.isEmpty || venues.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create at least 1 Organizer and 1 Venue first.')),
        );
      }
      return;
    }

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    String typeVal = existing?.eventType ?? types.first;
    final capCtrl = TextEditingController(text: (existing?.capacity ?? 100).toString());
    DateTime dateVal = existing?.eventDate ?? DateTime.now().add(const Duration(days: 7));
    bool isPublicVal = existing?.isPublic ?? true;
    final tagsCtrl = TextEditingController(text: (existing?.tags ?? []).join(','));
    final emailCtrl = TextEditingController(text: existing?.contactEmail ?? '');
    final extraCtrl = TextEditingController(text: jsonEncode(existing?.extraInfo ?? {'venueNotes': ''}));

    String orgId = existing?.organizerId.isNotEmpty == true ? existing!.organizerId : organizers.first.id;
    String venueId = existing?.venueId.isNotEmpty == true ? existing!.venueId : venues.first.id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title (lowercase on backend)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: typeVal,
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setLocal(() => typeVal = v ?? types.first),
                  decoration: const InputDecoration(labelText: 'Event type (enum)'),
                ),
                const SizedBox(height: 8),
                TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity (max enforced backend)')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Date: ${DateFormat('yyyy-MM-dd').format(dateVal)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDate: dateVal,
                        );
                        if (picked != null) setLocal(() => dateVal = picked);
                      },
                      child: const Text('Pick'),
                    )
                  ],
                ),
                SwitchListTile(
                  value: isPublicVal,
                  onChanged: (v) => setLocal(() => isPublicVal = v),
                  title: const Text('Public'),
                  contentPadding: EdgeInsets.zero,
                ),
                TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Contact email (validated)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: orgId,
                  items: organizers.map((o) => DropdownMenuItem(value: o.id, child: Text(o.orgName))).toList(),
                  onChanged: (v) => setLocal(() => orgId = v ?? organizers.first.id),
                  decoration: const InputDecoration(labelText: 'Organizer'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: venueId,
                  items: venues.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (v) => setLocal(() => venueId = v ?? venues.first.id),
                  decoration: const InputDecoration(labelText: 'Venue'),
                ),
                const SizedBox(height: 8),
                TextField(controller: extraCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'extraInfo (JSON)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;

    Map<String, dynamic> extra = {};
    try {
      extra = jsonDecode(extraCtrl.text) as Map<String, dynamic>;
    } catch (_) {}

    final cap = int.tryParse(capCtrl.text) ?? 0;
    final tags = tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final item = EventItem(
      id: existing?.id ?? '',
      title: titleCtrl.text.trim(),
      eventType: typeVal,
      capacity: cap,
      eventDate: dateVal,
      isPublic: isPublicVal,
      tags: tags,
      extraInfo: extra,
      contactEmail: emailCtrl.text.trim(),
      organizerId: orgId,
      organizer: null,
      venueId: venueId,
      venue: null,
    );

    setState(() => busy = true);
    try {
      if (existing == null) {
        await repo.create(item);
      } else {
        await repo.update(existing.id, item);
      }
      await _loadEvents();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BusyOverlay(
      busy: busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          actions: [
            IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openForm(),
          child: const Icon(Icons.add),
        ),
        body: err != null
            ? Center(child: Text(err!))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: eventTypeFilter.isEmpty ? null : eventTypeFilter,
                            hint: const Text('All types'),
                            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) {
                              setState(() => eventTypeFilter = v ?? '');
                              _loadEvents();
                            },
                            decoration: const InputDecoration(labelText: 'Filter: eventType'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: isPublicFilter == null ? 'all' : (isPublicFilter! ? 'true' : 'false'),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All visibility')),
                              DropdownMenuItem(value: 'true', child: Text('Public only')),
                              DropdownMenuItem(value: 'false', child: Text('Private only')),
                            ],
                            onChanged: (v) {
                              if (v == 'all') {
                                setState(() => isPublicFilter = null);
                              } else {
                                setState(() => isPublicFilter = (v == 'true'));
                              }
                              _loadEvents();
                            },
                            decoration: const InputDecoration(labelText: 'Filter: isPublic'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = items[i];
                        final orgName = e.organizer?.orgName ?? 'Organizer: ${e.organizerId}';
                        final venueName = e.venue?.name ?? 'Venue: ${e.venueId}';
                        return ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            '${e.eventType} • ${DateFormat('yyyy-MM-dd').format(e.eventDate)}\n'
                            'Cap: ${e.capacity} • ${e.isPublic ? 'Public' : 'Private'}\n'
                            '$orgName • $venueName',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openForm(existing: e),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
