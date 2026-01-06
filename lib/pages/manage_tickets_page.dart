import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../services/events_api.dart';
import '../services/tickets_api.dart';

class ManageTicketsPage extends StatefulWidget {
  const ManageTicketsPage({super.key});

  @override
  State<ManageTicketsPage> createState() => _ManageTicketsPageState();
}

class _ManageTicketsPageState extends State<ManageTicketsPage> {
  Future<List<TicketModel>> _loadTickets() => TicketsApi.fetchAll();
  Future<List<EventModel>> _loadEvents() => EventsApi.fetchAll();

  Future<void> _openEditor({TicketModel? existing}) async {
    final events = await _loadEvents();
    if (!mounted) return;

    EventModel? selectedEvent;
    if (existing != null) {
      selectedEvent = events.firstWhere(
        (e) => e.id == existing.event.id,
        orElse: () => events.isNotEmpty ? events.first : existing.event,
      );
    } else {
      selectedEvent = events.isNotEmpty ? events.first : null;
    }

    final buyerCtrl = TextEditingController(text: existing?.buyerName ?? '');
    final seatCtrl = TextEditingController(text: (existing?.seatNumber ?? 1).toString());
    bool checkedIn = existing?.checkedIn ?? false;
    final notesCtrl = TextEditingController(text: (existing?.notes ?? []).join(','));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'Create Ticket' : 'Edit Ticket'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (events.isEmpty)
                      const Text('Create an event first (Manage Events).')
                    else
                      DropdownButtonFormField<String>(
                        value: selectedEvent?.id,
                        decoration: const InputDecoration(labelText: 'Event'),
                        items: events
                            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.displayTitle)))
                            .toList(),
                        onChanged: (v) {
                          setLocal(() {
                            selectedEvent = events.firstWhere((e) => e.id == v);
                          });
                        },
                      ),
                    TextField(controller: buyerCtrl, decoration: const InputDecoration(labelText: 'Buyer Name')),
                    TextField(controller: seatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seat Number')),
                    SwitchListTile(
                      value: checkedIn,
                      onChanged: (v) => setLocal(() => checkedIn = v),
                      title: const Text('Checked In'),
                    ),
                   // TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: events.isEmpty ? null : () => Navigator.pop(ctx, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    if (selectedEvent == null) return;

    final body = <String, dynamic>{
      'buyerName': buyerCtrl.text.trim(),
      'seatNumber': int.tryParse(seatCtrl.text.trim()) ?? 0,
      'checkedIn': checkedIn,
      //'notes': notesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'payload': {'source': 'flutter'},
      'eventId': selectedEvent!.id,
    };

    try {
      if (existing == null) {
        await TicketsApi.createTicket(body);
      } else {
        await TicketsApi.updateTicket(existing.id, body);
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _delete(TicketModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: Text('Delete ticket for "${t.buyerName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await TicketsApi.deleteTicket(t.id);
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tickets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TicketModel>>(
        future: _loadTickets(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No tickets yet. Tap + to create one.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              return ListTile(
                title: Text('${t.buyerName} • seat ${t.seatNumber}'),
                subtitle: Text('${t.event.displayTitle} • checkedIn: ${t.checkedIn}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditor(existing: t)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(t)),
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
