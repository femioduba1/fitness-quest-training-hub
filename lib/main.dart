import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/create_quest_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/ai_trainer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progress_photos_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/slide_menu.dart';

/// Entry point — initializes notifications then launches app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification plugin and request permissions
  await NotificationService.instance.initialize();

  // Schedule daily motivational quotes in background
  NotificationService.instance
      .scheduleMotivationalNotifications()
      .catchError((e) => debugPrint('Schedule error: $e'));

  runApp(FitnessQuestApp(key: FitnessQuestApp.appKey));
}

/// Root app widget — manages global theme state
class FitnessQuestApp extends StatefulWidget {
  const FitnessQuestApp({super.key});

  /// Global key used by SettingsScreen to update theme from anywhere
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

  /// Loads saved theme preference from SharedPreferences on startup
  Future<void> _loadTheme() async {
    final saved =
        await PreferencesService.instance.getThemeMode();
    setState(() => _themeMode = _toThemeMode(saved));
  }

  /// Called by SettingsScreen after toggle animation completes
  void updateTheme(String mode) {
    setState(() => _themeMode = _toThemeMode(mode));
  }

  /// Converts string preference to Flutter ThemeMode
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
      home: const AppEntry(),
    );
  }
}

/// Global key to access the slide menu from any screen
final GlobalKey<SlideMenuState> menuKey =
    GlobalKey<SlideMenuState>();

/// Global key to access navigation state
final GlobalKey<_MainNavigationState> navKey =
    GlobalKey<_MainNavigationState>();

/// Checks if user has completed onboarding
/// Shows onboarding on first launch, main app otherwise
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _loading = true;
  bool _hasOnboarded = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  /// Checks SharedPreferences to see if onboarding was completed
  Future<void> _checkOnboarding() async {
    final hasOnboarded =
        await PreferencesService.instance.getHasOnboarded();
    if (mounted) {
      setState(() {
        _hasOnboarded = hasOnboarded;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while checking onboarding status
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚡', style: TextStyle(fontSize: 60)),
              SizedBox(height: 16),
              Text(
                'FITNESS QUEST',
                style: TextStyle(
                  color: AppTheme.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Route to onboarding or main app
    return _hasOnboarded
        ? const MainNavigation()
        : const OnboardingScreen();
  }
}

/// Main navigation shell — wraps all screens in the slide menu
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  /// All 7 screens accessible via the burger menu
  final List<Widget> _screens = const [
    HomeScreen(),
    ExerciseLibraryScreen(),
    CreateQuestScreen(),
    ProgressScreen(),
    AITrainerScreen(),
    SettingsScreen(),
    ProgressPhotosScreen(),
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
      // AnimatedSwitcher provides smooth fade+slide between screens
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