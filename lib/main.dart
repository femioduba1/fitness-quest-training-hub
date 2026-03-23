import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/create_quest_screen.dart';
import 'screens/progress_screen.dart';

// Entry point of the app
void main() {
  runApp(const FitnessQuestApp());
}

// This is the root of the app
// It sets up the overall theme and initial screen
class FitnessQuestApp extends StatelessWidget {
  const FitnessQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Quest',

      // Removes the debug banner in the top right
      debugShowCheckedModeBanner: false,

      // Global app theme (colors, styling, etc.)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),

      // Main navigation screen that controls all tabs
      home: const MainNavigation(),
    );
  }
}

// This widget controls the bottom navigation bar
// and switches between different screens
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  // Keeps track of which tab is currently selected
  int _selectedIndex = 0;

  // List of all screens in the app
  // The index corresponds to the selected tab
  final List<Widget> _screens = const [
    HomeScreen(),
    ExerciseLibraryScreen(),
    CreateQuestScreen(),
    ProgressScreen(),
  ];

  // This function runs when a user taps a tab
  // It updates the selected index and refreshes the UI
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Displays the currently selected screen
      body: _screens[_selectedIndex],

      // Bottom navigation bar for switching between screens
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,

        // Each destination represents a screen/tab
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}