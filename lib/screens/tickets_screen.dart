import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/ticket.dart';
import '../services/event_repo.dart';
import '../services/ticket_repo.dart';
import '../widgets/busy_overlay.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final repo = TicketRepo();
  final eventRepo = EventRepo();

  bool busy = false;
  String? err;

  List<Ticket> items = [];
  List<EventItem> events = [];
  String eventFilterId = '';

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
      final evs = await eventRepo.list();
      final tks = await repo.list(eventId: eventFilterId.isEmpty ? null : eventFilterId);
      setState(() {
        events = evs;
        items = tks;
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _openForm({Ticket? existing}) async {
    if (events.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create at least 1 Event first.')),
        );
      }
      return;
    }

    String eventId = existing?.eventId.isNotEmpty == true ? existing!.eventId : events.first.id;
    final buyerCtrl = TextEditingController(text: existing?.buyerName ?? '');
    final seatCtrl = TextEditingController(text: (existing?.seatNumber ?? 1).toString());
    bool checkedInVal = existing?.checkedIn ?? false;
    DateTime purchaseVal = existing?.purchaseDate ?? DateTime.now();
    final addonsCtrl = TextEditingController(text: (existing?.addons ?? []).join(','));
    final answersCtrl = TextEditingController(text: jsonEncode(existing?.answers ?? {'diet': 'none'}));

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add Ticket' : 'Edit Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: eventId,
                  items: events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList(),
                  onChanged: (v) => setLocal(() => eventId = v ?? events.first.id),
                  decoration: const InputDecoration(labelText: 'Event'),
                ),
                TextField(controller: buyerCtrl, decoration: const InputDecoration(labelText: 'Buyer name')),
                TextField(controller: seatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seat number')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Purchase: ${DateFormat('yyyy-MM-dd').format(purchaseVal)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDate: purchaseVal,
                        );
                        if (picked != null) setLocal(() => purchaseVal = picked);
                      },
                      child: const Text('Pick'),
                    )
                  ],
                ),
                SwitchListTile(
                  value: checkedInVal,
                  onChanged: (v) => setLocal(() => checkedInVal = v),
                  title: const Text('Checked in'),
                  contentPadding: EdgeInsets.zero,
                ),
                TextField(controller: addonsCtrl, decoration: const InputDecoration(labelText: 'Addons (comma separated)')),
                TextField(controller: answersCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Answers (JSON)')),
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

    Map<String, dynamic> answers = {};
    try {
      answers = jsonDecode(answersCtrl.text) as Map<String, dynamic>;
    } catch (_) {}

    final seat = int.tryParse(seatCtrl.text) ?? 1;
    final addons = addonsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final ticket = Ticket(
      id: existing?.id ?? '',
      eventId: eventId,
      buyerName: buyerCtrl.text.trim(),
      seatNumber: seat,
      purchaseDate: purchaseVal,
      checkedIn: checkedInVal,
      addons: addons,
      answers: answers,
    );

    setState(() => busy = true);
    try {
      if (existing == null) {
        await repo.create(ticket);
      } else {
        await repo.update(existing.id, ticket);
      }
      await _loadAll();
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
          title: const Text('Tickets'),
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
                    child: DropdownButtonFormField<String>(
                      value: eventFilterId.isEmpty ? 'all' : eventFilterId,
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All events')),
                        ...events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => eventFilterId = (v == 'all') ? '' : v);
                        _loadAll();
                      },
                      decoration: const InputDecoration(labelText: 'Filter by eventId'),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final t = items[i];
                        return ListTile(
                          title: Text(t.buyerName),
                          subtitle: Text(
                            'Seat: ${t.seatNumber} • ${t.checkedIn ? 'Checked-in' : 'Not checked-in'}\n'
                            'Purchase: ${DateFormat('yyyy-MM-dd').format(t.purchaseDate)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openForm(existing: t),
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
