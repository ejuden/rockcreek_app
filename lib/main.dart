// Rock Creek Church App - Entry Point
//
// This is the main entry point for the app. It sets up:
// - MaterialApp with the church brand theme
// - A 4-tab BottomNavigationBar (Home, Sermons, Events, Connect)
// - IndexedStack to preserve tab state when switching between tabs
//
// To change the brand color, update the hex value 0xFF2E86AB below.
// To add a new tab, add an entry to _screens, _titles, and the
// BottomNavigationBar items list in _MainShellState.
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sermons_screen.dart';
import 'screens/events_screen.dart';
import 'screens/connect_screen.dart';

void main() {
  runApp(const RockCreekApp());
}

class RockCreekApp extends StatelessWidget {
  const RockCreekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Creek Church',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Brand color: update this hex value to change the app-wide accent color.
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2E86AB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E86AB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E86AB),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// Shell widget that hosts the BottomNavigationBar and swaps between tabs.
/// Uses IndexedStack so each tab keeps its scroll position and state.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Tab screens — order must match the BottomNavigationBar items below.
  final _screens = const <Widget>[
    HomeScreen(),
    SermonsScreen(),
    EventsScreen(),
    ConnectScreen(),
  ];

  // AppBar titles — order must match _screens.
  final _titles = const <String>[
    'Rock Creek Church',
    'Sermons',
    'Events',
    'Connect',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Sermons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Connect',
          ),
        ],
      ),
    );
  }
}
