import 'package:flutter/material.dart';
import 'organizers_screen.dart';
import 'venues_screen.dart';
import 'events_screen.dart';
import 'tickets_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  final _pages = const [
    EventsScreen(),
    TicketsScreen(),
    ReportsScreen(),
    OrganizersScreen(),
    VenuesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (v) => setState(() => _idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Organizers'),
          NavigationDestination(icon: Icon(Icons.place), label: 'Venues'),
        ],
      ),
    );
  }
}
