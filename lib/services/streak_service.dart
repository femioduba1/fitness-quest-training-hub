import '../database/crud/workout_log_crud.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages workout streak calculation and persistence using SharedPreferences
/// A streak increments when the user logs at least one workout per day
class StreakService {
  static final StreakService instance = StreakService._internal();
  StreakService._internal();

  final WorkoutLogCrud _logCrud = WorkoutLogCrud();

  // SharedPreferences keys for streak data
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyLastWorkoutDate = 'last_workout_date';

  /// Calculates current streak based on last workout date
  /// Returns 0 if streak has been broken (missed more than 1 day)
  Future<int> calculateCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWorkoutDate = prefs.getString(_keyLastWorkoutDate);
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;

    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final yesterdayStr =
        _formatDate(today.subtract(const Duration(days: 1)));

    if (lastWorkoutDate == null) return 0;
    if (lastWorkoutDate == todayStr) return currentStreak;
    if (lastWorkoutDate == yesterdayStr) return currentStreak;

    // Streak broken — reset to 0
    await prefs.setInt(_keyCurrentStreak, 0);
    return 0;
  }

  /// Records a workout for today and updates streak accordingly
  /// Prevents double-counting multiple workouts on the same day
  Future<void> recordWorkoutToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastWorkoutDate = prefs.getString(_keyLastWorkoutDate);

    if (lastWorkoutDate == today) return;

    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final yesterday = _formatDate(
        DateTime.now().subtract(const Duration(days: 1)));

    if (lastWorkoutDate == yesterday) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }

    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setString(_keyLastWorkoutDate, today);

    // Update longest streak if current exceeds it
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    if (currentStreak > longestStreak) {
      await prefs.setInt(_keyLongestStreak, currentStreak);
    }
  }

  Future<int> getCurrentStreak() async =>
      await calculateCurrentStreak();

  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLongestStreak) ?? 0;
  }

  Future<String?> getLastWorkoutDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastWorkoutDate);
  }

  /// Checks if the user has logged at least one workout today
  Future<bool> hasWorkedOutToday() async {
    final logs = await _logCrud.getTodaysLogs();
    return logs.isNotEmpty;
  }

  /// Formats a DateTime to YYYY-MM-DD string for comparison
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}