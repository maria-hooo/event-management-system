import 'package:flutter/material.dart';
import '../utils/event_navigation.dart'; // adjust path if needed


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int selectedTab = 0;

  final tabs = ["Today", "This Week", "This Month"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tabs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- EVENT LIST ----------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _buildEventsForTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventsForTab() {
    // Fake data for now
    if (selectedTab == 0) {
      return const [
        CalendarEventTile(
          title: "Morning Yoga",
          time: "10:00 AM",
          location: "Berlin",
        ),
        CalendarEventTile(
          title: "Tech Meetup",
          time: "6:00 PM",
          location: "Berlin",
        ),
      ];
    } else if (selectedTab == 1) {
      return const [
        CalendarEventTile(
          title: "Live Concert",
          time: "Friday",
          location: "Paris",
        ),
        CalendarEventTile(
          title: "Startup Demo Day",
          time: "Saturday",
          location: "London",
        ),
      ];
    } else {
      return const [
        CalendarEventTile(
          title: "Music Festival",
          time: "Jan 28",
          location: "Amsterdam",
        ),
      ];
    }
  }
}

class CalendarEventTile extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final String imageUrl; // optional, for event details
  final String price; // optional, for event details

  const CalendarEventTile({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    this.imageUrl = "https://picsum.photos/400/300?20", // fallback image
    this.price = "0",
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Navigate to Event Details page
        goToEventDetails(
          context: context,
          name: title,
          date: time,
          location: location,
          imageUrl: imageUrl,
          price: price,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            // TIME
            Container(
              width: 64,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
