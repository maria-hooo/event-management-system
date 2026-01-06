import 'package:flutter/material.dart';

import 'profile.dart'; // make sure this path is correct in your project
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
  // criteria #1
  String? _selectedCategory;

  // criteria #2 (null = all)
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
              const _SearchBar(),
              const SizedBox(height: 28),
              const _SectionHeader(title: "🔥 Featured Events"),
              const SizedBox(height: 16),
              _FeaturedCarousel(),
              const SizedBox(height: 28),
              const _SectionHeader(title: "🎤 Popular Events"),
              const SizedBox(height: 16),
              _PopularEvents(
                selectedCategory: _selectedCategory,
                isPublic: _isPublic,
              ),
              const SizedBox(height: 28),
              const _SectionHeader(title: "📅 Upcoming Events"),
              const SizedBox(height: 16),
              _UpcomingEvents(
                selectedCategory: _selectedCategory,
                isPublic: _isPublic,
              ),
              const SizedBox(height: 28),
              const _SectionHeader(title: "🎨 Categories"),
              const SizedBox(height: 16),
              _Categories(
                selectedCategory: _selectedCategory,
                isPublic: _isPublic,
                onCategoryChanged: (v) => setState(() => _selectedCategory = v),
                onPublicChanged: (v) => setState(() => _isPublic = v),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Optional: if you want it visible
      // bottomNavigationBar: const _BottomNav(),
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
                  // NOTE: Some networks block this URL on web sometimes.
                  // If it fails, replace with a local asset or another URL.
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Hello 👋",
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

/* ---------------- SEARCH ---------------- */
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text("Find amazing events", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/* ---------------- SECTION HEADER ---------------- */
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Text(
            "View All",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/* ---------------- FEATURED CAROUSEL ---------------- */
class _FeaturedCarousel extends StatelessWidget {
  _FeaturedCarousel();

  final List<String> images = const [
    "https://picsum.photos/600/300?1",
    "https://picsum.photos/600/300?2",
    "https://picsum.photos/600/300?3",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: images.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(images[index], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/* ---------------- POPULAR EVENTS ---------------- */
class _PopularEvents extends StatelessWidget {
  final String? selectedCategory;
  final bool? isPublic;

  const _PopularEvents({this.selectedCategory, this.isPublic});

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
                "Failed to load events:\n${snap.error}",
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final events = (snap.data ?? []).take(10).toList();
        if (events.isEmpty) {
          return const SizedBox(
            height: 260,
            child: Center(
              child: Text("No events found", style: TextStyle(color: Colors.black54)),
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

              return _EventCard(
                name: e.displayTitle,
                date: "${e.startDate.toLocal()}".split(".").first,
                location: e.location,
                price: e.price.toStringAsFixed(0),
                image: e.imageUrl,
                onTap: () {
                  goToEventDetails(
                    context: context,
                    eventId: e.id,
                    name: e.displayTitle,
                    date: "${e.startDate.toLocal()}".split(".").first,
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
                "Failed to load events:\n${snap.error}",
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
              child: Text("No upcoming events", style: TextStyle(color: Colors.black54)),
            ),
          );
        }

        return Column(
          children: events.take(6).map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(e.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                ),
                title: Text(e.displayTitle, style: const TextStyle(color: Colors.black)),
                subtitle: Text(
                  "${e.startDate.toLocal()}".split(".").first,
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Text("\$${e.price.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.black)),
                onTap: () {
                  goToEventDetails(
                    context: context,
                    eventId: e.id,
                    name: e.displayTitle,
                    date: "${e.startDate.toLocal()}".split(".").first,
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

/* ---------------- CATEGORIES / FILTERS ---------------- */
class _Categories extends StatelessWidget {
  final String? selectedCategory;
  final bool? isPublic;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool?> onPublicChanged;

  const _Categories({
    required this.selectedCategory,
    required this.isPublic,
    required this.onCategoryChanged,
    required this.onPublicChanged,
  });

  // Must match backend enum: ["music","sports","tech","art","business"]
  static const List<Map<String, String>> _cats = [
    {"label": "All", "value": ""},
    {"label": "Music", "value": "music"},
    {"label": "Sports", "value": "sports"},
    {"label": "Tech", "value": "tech"},
    {"label": "Art", "value": "art"},
    {"label": "Business", "value": "business"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final c = _cats[index];
              final v = c["value"]!;
              final isSelected =
                  (v.isEmpty && selectedCategory == null) || selectedCategory == v;

              return ChoiceChip(
                label: Text(c["label"]!),
                selected: isSelected,
                onSelected: (_) => onCategoryChanged(v.isEmpty ? null : v),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text("Visibility:", style: TextStyle(color: Colors.black54)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("All"),
                selected: isPublic == null,
                onSelected: (_) => onPublicChanged(null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Public"),
                selected: isPublic == true,
                onSelected: (_) => onPublicChanged(true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Private"),
                selected: isPublic == false,
                onSelected: (_) => onPublicChanged(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ---------------- EVENT CARD (was missing in your file) ---------------- */
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

/* ---------------- OPTIONAL BOTTOM NAV ---------------- */
class _BottomNav extends StatelessWidget {
  const _BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 64,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: ""),
        NavigationDestination(icon: Icon(Icons.calendar_today), label: ""),
        NavigationDestination(icon: Icon(Icons.bookmark), label: ""),
        NavigationDestination(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}
