import 'package:flutter/material.dart';
import '../utils/event_navigation.dart';
import '../services/events_api.dart';
import '../models/event_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  late Future<List<EventModel>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventsApi.fetchAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _filter(List<EventModel> events) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return events;

    return events.where((e) {
      final haystack =
          "${e.displayTitle} ${e.location} ${e.category}".toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  String _formatDate(DateTime d) {
    // Simple format to keep it lightweight (no intl dependency)
    // Example: 2026-01-20 20:00
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return "$y-$m-$day $hh:$mm";
  }

  Future<void> _refresh() async {
    setState(() {
      _futureEvents = EventsApi.fetchAll();
    });
    await _futureEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---------- SEARCH BAR ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: "Search events, artists, cities.",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: "Clear",
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = "");
                          },
                        ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ---------- FILTER CHIPS (UI only for now) ----------
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _FilterChip(label: "Today"),
                  _FilterChip(label: "This Week"),
                  _FilterChip(label: "Music"),
                  _FilterChip(label: "Art"),
                  _FilterChip(label: "Free"),
                  _FilterChip(label: "Nearby"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---------- RESULTS ----------
            Expanded(
              child: FutureBuilder<List<EventModel>>(
                future: _futureEvents,
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
                  final results = _filter(events);

                  if (results.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _query.trim().isEmpty
                              ? "No events found."
                              : 'No results for "${_query.trim()}".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final e = results[index];

                        return ExploreEventCard(
                          // ✅ IMPORTANT: MongoDB real ObjectId string (fixes booking)
                          eventId: e.id,
                          title: e.displayTitle,
                          date: _formatDate(e.startDate),
                          location: e.location,
                          imageUrl: e.imageUrl,
                          price: e.price.toStringAsFixed(0),
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

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ExploreEventCard extends StatelessWidget {
  final String eventId;
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String price;

  const ExploreEventCard({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.price = "0",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        goToEventDetails(
          context: context,
          eventId: eventId, // ✅ real ObjectId
          name: title,
          date: date,
          location: location,
          imageUrl: imageUrl,
          price: price,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(date, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 14),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\$$price",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
