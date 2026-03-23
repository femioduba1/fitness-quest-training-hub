import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/create_quest_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/ai_trainer_screen.dart';
import 'screens/settings_screen.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/slide_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  NotificationService.instance
      .scheduleMotivationalNotifications()
      .catchError((e) => debugPrint('Schedule error: $e'));
  runApp(FitnessQuestApp(key: FitnessQuestApp.appKey));
}

class FitnessQuestApp extends StatefulWidget {
  const FitnessQuestApp({super.key});

  static final GlobalKey<_FitnessQuestAppState> appKey =
      GlobalKey<_FitnessQuestAppState>();

  @override
  State<FitnessQuestApp> createState() =>
      _FitnessQuestAppState();
}

class _FitnessQuestAppState extends State<FitnessQuestApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved =
        await PreferencesService.instance.getThemeMode();
    setState(() => _themeMode = _toThemeMode(saved));
  }

  void updateTheme(String mode) {
    setState(() => _themeMode = _toThemeMode(mode));
  }

  ThemeMode _toThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Quest',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

final GlobalKey<SlideMenuState> menuKey =
    GlobalKey<SlideMenuState>();
final GlobalKey<_MainNavigationState> navKey =
    GlobalKey<_MainNavigationState>();

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExerciseLibraryScreen(),
    CreateQuestScreen(),
    ProgressScreen(),
    AITrainerScreen(),
    SettingsScreen(),
  ];

  void navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SlideMenu(
      key: menuKey,
      currentIndex: _selectedIndex,
      onNavigate: (index) {
        setState(() => _selectedIndex = index);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
    );
  }
}