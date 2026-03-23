import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/create_quest_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FitnessQuestApp(key: FitnessQuestApp.appKey));
}

class FitnessQuestApp extends StatefulWidget {
  const FitnessQuestApp({super.key});

  // Global key so SettingsScreen can call updateTheme() from anywhere
  static final GlobalKey<_FitnessQuestAppState> appKey =
      GlobalKey<_FitnessQuestAppState>();

  @override
  State<FitnessQuestApp> createState() => _FitnessQuestAppState();
}

class _FitnessQuestAppState extends State<FitnessQuestApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load saved theme on app startup
  Future<void> _loadTheme() async {
    final saved = await PreferencesService.instance.getThemeMode();
    setState(() {
      _themeMode = _toThemeMode(saved);
    });
  }

  // Called by SettingsScreen when user changes theme
  void updateTheme(String mode) {
    setState(() {
      _themeMode = _toThemeMode(mode);
    });
  }

  ThemeMode _toThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Quest',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExerciseLibraryScreen(),
    CreateQuestScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
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
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}