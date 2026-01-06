import 'package:flutter/material.dart';
import '../utils/event_navigation.dart';
import 'manage_events_page.dart';
import 'manage_organizers_page.dart';
import 'manage_tickets_page.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onBack;

  const ProfilePage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 240, 236),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.pop(context),
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
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
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
