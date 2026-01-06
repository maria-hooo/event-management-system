import 'package:flutter/material.dart';
import 'pages/discover_events_page.dart';
import 'pages/profile.dart';
import 'pages/explore_page.dart';
import 'pages/calendar_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evenfonic',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const DiscoverApp(),
    );
  }
}

class DiscoverApp extends StatefulWidget {
  const DiscoverApp({super.key});

  @override
  State<DiscoverApp> createState() => _DiscoverAppState();
}

class _DiscoverAppState extends State<DiscoverApp> {
  int _currentIndex = 0; // always starts valid

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
_pages = [
  DiscoverEventsPage(
    onProfileTap: () {
      setState(() {
        _currentIndex = 3; // switch to Profile tab
      });
    },
  ),
  const ExplorePage(),
  const CalendarPage(),
  ProfilePage(
    onBack: () {
      setState(() {
        _currentIndex = 0; // go back to Discover page
      });
    },
  ),
];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Explore"),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
