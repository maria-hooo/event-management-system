import 'package:flutter/material.dart';
import '../services/event_repo.dart';
import '../services/ticket_repo.dart';
import '../widgets/busy_overlay.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool busy = false;
  String? err;

  final eventRepo = EventRepo();
  final ticketRepo = TicketRepo();

  List<Map<String, dynamic>> eventAgg = [];
  List<Map<String, dynamic>> ticketAgg = [];

  Future<void> _load() async {
    setState(() {
      busy = true;
      err = null;
    });
    try {
      final e = await eventRepo.aggregate();
      final t = await ticketRepo.report();
      setState(() {
        eventAgg = e;
        ticketAgg = t;
      });
    } catch (ex) {
      setState(() => err = ex.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return BusyOverlay(
      busy: busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports (Aggregate)'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: err != null
            ? Center(child: Text(err!))
            : ListView(
                children: [
                  const ListTile(
                    title: Text('Events Aggregate'),
                    subtitle: Text('GET /events-aggregate (lookup join)'),
                  ),
                  ...eventAgg.map((row) => ListTile(
                        title: Text(row['title']?.toString() ?? ''),
                        subtitle: Text(
                          'Type: ${row['eventType']} • Cap: ${row['capacity']} • Public: ${row['isPublic']}\n'
                          'Organizer: ${row['organizerName'] ?? ''} • Venue: ${row['venueName'] ?? ''}',
                        ),
                        isThreeLine: true,
                      )),
                  const Divider(),
                  const ListTile(
                    title: Text('Tickets Report'),
                    subtitle: Text('GET /tickets-report (lookup join)'),
                  ),
                  ...ticketAgg.map((row) => ListTile(
                        title: Text(row['buyerName']?.toString() ?? ''),
                        subtitle: Text(
                          'Event: ${row['eventTitle'] ?? ''}\n'
                          'CheckedIn: ${row['checkedIn'] ?? false} • Seat: ${row['seatNumber'] ?? ''}',
                        ),
                        isThreeLine: true,
                      )),
                ],
              ),
      ),
    );
  }
}
