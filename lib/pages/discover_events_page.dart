import 'package:flutter/material.dart';

import 'profile.dart';
import '../utils/event_navigation.dart';
import '../services/events_api.dart';
import '../models/event_model.dart';

class DiscoverEventsPage extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DiscoverEventsPage({
    super.key,
    this.onProfileTap,
  });

  @override
  State<DiscoverEventsPage> createState() => _DiscoverEventsPageState();
}

class _DiscoverEventsPageState extends State<DiscoverEventsPage> {
  String? _selectedCategory;
  bool? _isPublic;

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onProfileTap: widget.onProfileTap ?? () => _openProfile(context),
              ),
              const SizedBox(height: 24),

              // SECTION 1: Featured
              const _SectionIntro(
                title: "Featured events",
                description: "Handpicked events you should not miss.",
              ),
              const SizedBox(height: 12),
              _FeaturedEvents(
                selectedCategory: _selectedCategory,
                isPublic: _isPublic,
              ),

              const SizedBox(height: 28),

              // SECTION 2: Upcoming
              const _SectionIntro(
                title: "Upcoming events",
                description: "What is happening soon, sorted by date.",
              ),
              const SizedBox(height: 12),
              _UpcomingEvents(
                selectedCategory: _selectedCategory,
                isPublic: _isPublic,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- HEADER ---------------- */
class _Header extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const _Header({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Evenfonic",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Hello",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          const Text(
            "Discover Amazing Events",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- SECTION INTRO ---------------- */
class _SectionIntro extends StatelessWidget {
  final String title;
  final String description;

  const _SectionIntro({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/* ---------------- HELPERS ---------------- */
String _dateOnly(DateTime dt) => dt.toLocal().toString().split(' ').first;

/* ---------------- FEATURED EVENTS ---------------- */
class _FeaturedEvents extends StatelessWidget {
  final String? selectedCategory;
  final bool? isPublic;

  const _FeaturedEvents({this.selectedCategory, this.isPublic});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: (selectedCategory == null && isPublic == null)
          ? EventsApi.fetchAll()
          : EventsApi.fetchFiltered(category: selectedCategory, isPublic: isPublic),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return SizedBox(
            height: 260,
            child: Center(
              child: Text(
                "Failed to load featured events\n${snap.error}",
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // This is still "first N events" until backend gives a true featured flag
        final events = (snap.data ?? []).take(10).toList();

        if (events.isEmpty) {
          return const SizedBox(
            height: 260,
            child: Center(
              child: Text(
                "No featured events right now",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, index) {
              final e = events[index];
              final dateStr = _dateOnly(e.startDate);

              return _EventCard(
                name: e.displayTitle,
                date: dateStr,
                location: e.location,
                price: e.price.toStringAsFixed(0),
                image: e.imageUrl,
                onTap: () {
                  goToEventDetails(
                    context: context,
                    eventId: e.id,
                    name: e.displayTitle,
                    date: dateStr,
                    location: e.location,
                    imageUrl: e.imageUrl,
                    price: e.price.toStringAsFixed(0),
                    description:
                        "Category: ${e.category}\nOrganizer: ${e.organizer.name}\nPublic: ${e.isPublic}\nTags: ${e.tags.join(", ")}",
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/* ---------------- UPCOMING EVENTS ---------------- */
class _UpcomingEvents extends StatelessWidget {
  final String? selectedCategory;
  final bool? isPublic;

  const _UpcomingEvents({this.selectedCategory, this.isPublic});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: (selectedCategory == null && isPublic == null)
          ? EventsApi.fetchAll()
          : EventsApi.fetchFiltered(category: selectedCategory, isPublic: isPublic),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return SizedBox(
            height: 160,
            child: Center(
              child: Text(
                "Failed to load upcoming events\n${snap.error}",
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final events = (snap.data ?? []).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

        if (events.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                "No upcoming events",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return Column(
          children: events.take(6).map((e) {
            final dateStr = _dateOnly(e.startDate);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    e.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                title: Text(e.displayTitle, style: const TextStyle(color: Colors.black)),
                subtitle: Text(dateStr, style: const TextStyle(color: Colors.black54)),
                trailing: Text(
                  "\$${e.price.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  goToEventDetails(
                    context: context,
                    eventId: e.id,
                    name: e.displayTitle,
                    date: dateStr,
                    location: e.location,
                    imageUrl: e.imageUrl,
                    price: e.price.toStringAsFixed(0),
                    description:
                        "Category: ${e.category}\nOrganizer: ${e.organizer.name}\nPublic: ${e.isPublic}\nTags: ${e.tags.join(", ")}",
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/* ---------------- EVENT CARD ---------------- */
class _EventCard extends StatelessWidget {
  final String name;
  final String date;
  final String location;
  final String price;
  final String image;
  final VoidCallback onTap;

  const _EventCard({
    required this.name,
    required this.date,
    required this.location,
    required this.price,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$$price",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
