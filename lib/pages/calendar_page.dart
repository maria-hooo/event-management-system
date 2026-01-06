import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../services/events_api.dart';
import '../utils/event_navigation.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int selectedTab = 0;
  final tabs = const ["Today", "This Week", "This Month"];

  late Future<List<EventModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = EventsApi.fetchAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = EventsApi.fetchAll();
    });
    await _future;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _startOfWeek(DateTime d) {
    // Monday = 1 ... Sunday = 7
    final day = DateTime(d.year, d.month, d.day);
    final diff = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: diff));
  }

  bool _isToday(DateTime d, DateTime now) {
    final a = _startOfDay(d);
    final b = _startOfDay(now);
    return a == b;
  }

  bool _isThisWeek(DateTime d, DateTime now) {
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    return d.isAfter(start.subtract(const Duration(seconds: 1))) && d.isBefore(end);
  }

  bool _isThisMonth(DateTime d, DateTime now) {
    return d.year == now.year && d.month == now.month;
  }

  String _formatShortDateTime(DateTime d) {
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return "$y-$m-$day $hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: const [
                  Text(
                    "Calendar",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // ---------- TABS ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = index == selectedTab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- EVENT LIST ----------
            Expanded(
              child: FutureBuilder<List<EventModel>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Failed to load events:\n${snap.error}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refresh,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final events = snap.data ?? const <EventModel>[];
                  final now = DateTime.now();

                  final filtered = events.where((e) {
                    final d = e.startDate;
                    if (selectedTab == 0) return _isToday(d, now);
                    if (selectedTab == 1) return _isThisWeek(d, now);
                    return _isThisMonth(d, now);
                  }).toList()
                    ..sort((a, b) => a.startDate.compareTo(b.startDate));

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              "No events for ${tabs[selectedTab]}",
                              style: const TextStyle(color: Colors.black54, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              "Pull down to refresh",
                              style: TextStyle(color: Colors.black38, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final e = filtered[i];
                        return CalendarEventTile(
                          eventId: e.id, // ✅ REAL MongoDB ObjectId string
                          title: e.displayTitle,
                          timeLabel: _formatShortDateTime(e.startDate),
                          location: e.location,
                          imageUrl: e.imageUrl,
                          price: e.price.toStringAsFixed(0),
                          category: e.category,
                          isPublic: e.isPublic,
                        );
                      },
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

class CalendarEventTile extends StatelessWidget {
  final String eventId;
  final String title;
  final String timeLabel;
  final String location;

  final String imageUrl;
  final String price;

  final String category;
  final bool isPublic;

  const CalendarEventTile({
    super.key,
    required this.eventId,
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.isPublic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        goToEventDetails(
          context: context,
          eventId: eventId, // ✅ so booking saves correctly
          name: title,
          date: timeLabel,
          location: location,
          imageUrl: imageUrl,
          price: price,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            // LEFT TIME BOX
            Container(
              width: 86,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    timeLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // MAIN INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Badge(text: category, bg: Colors.grey.shade200, fg: Colors.black87),
                      _Badge(
                        text: isPublic ? "Public" : "Private",
                        bg: isPublic ? Colors.green.shade50 : Colors.red.shade50,
                        fg: isPublic ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                      _Badge(text: "\$$price", bg: Colors.orange.shade50, fg: Colors.orange.shade800),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // THUMBNAIL
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
