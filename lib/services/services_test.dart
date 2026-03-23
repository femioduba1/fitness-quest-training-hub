import 'preferences_service.dart';
import 'streak_service.dart';

Future<void> runServicesTests() async {
  print('=== Starting Services Tests ===');

  // Test Preferences
  final prefs = PreferencesService.instance;

  await prefs.setUserName('Adrit');
  final name = await prefs.getUserName();
  print('✅ Username saved: $name');

  await prefs.setThemeMode('dark');
  final theme = await prefs.getThemeMode();
  print('✅ Theme saved: $theme');

  await prefs.setWeightUnit('lbs');
  final unit = await prefs.getWeightUnit();
  print('✅ Weight unit saved: $unit');

  // Test Streak
  final streak = StreakService.instance;

  await streak.recordWorkoutToday();
  final current = await streak.getCurrentStreak();
  print('✅ Current streak: $current');

  final longest = await streak.getLongestStreak();
  print('✅ Longest streak: $longest');

  final workedOut = await streak.hasWorkedOutToday();
  print('✅ Worked out today: $workedOut');

  print('=== All Services Tests Passed ===');
}