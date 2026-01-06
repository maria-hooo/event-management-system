import 'package:flutter/material.dart';
import '../utils/event_navigation.dart';
import 'manage_events_page.dart';
import 'manage_organizers_page.dart';
import 'manage_tickets_page.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onBack; // <-- new

  const ProfilePage({super.key, this.onBack}); // <-- new

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 240, 236),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack, // <-- call the callback instead of Navigator.pop
        ),
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- USER INFO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150",
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "John Doe",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Loves concerts & festivals 🎶",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- SAVED / FAVORITE EVENTS ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: "Saved Events ⭐"),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    EventCard(
                      name: "EDM Party",
                      date: "10 Feb",
                      location: "Amsterdam",
                      imageUrl: "https://picsum.photos/400/300?5",
                      onTap: () {
                        goToEventDetails(
                          context: context,
                          name: "EDM Party",
                          date: "10 Feb",
                          location: "Amsterdam",
                          imageUrl: "https://picsum.photos/400/300?5",
                          price: "50",
                        );
                      },
                    ),
                    EventCard(
                      name: "Art & Music Fest",
                      date: "22 Feb",
                      location: "Paris",
                      imageUrl: "https://picsum.photos/400/300?6",
                      onTap: () {
                        goToEventDetails(
                          context: context,
                          name: "Art & Music Fest",
                          date: "22 Feb",
                          location: "Paris",
                          imageUrl: "https://picsum.photos/400/300?6",
                          price: "70",
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- ACCOUNT / SETTINGS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileButton(
                      label: "Manage Events",
                      icon: Icons.event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageEventsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ProfileButton(
                      label: "Manage Organizers",
                      icon: Icons.people,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageOrganizersPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ProfileButton(
                      label: "Manage Tickets",
                      icon: Icons.confirmation_number,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageTicketsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ProfileButton(
                      label: "Edit Profile",
                      icon: Icons.edit,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    ProfileButton(
                      label: "Notifications",
                      icon: Icons.notifications,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    ProfileButton(
                      label: "Logout",
                      icon: Icons.logout,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- HELPER WIDGETS ---

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class EventCard extends StatelessWidget {
  final String name;
  final String date;
  final String location;
  final String imageUrl;
  final VoidCallback? onTap; // <-- new

  const EventCard({
    required this.name,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.onTap, // <-- new
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // <-- calls navigation
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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

class ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
