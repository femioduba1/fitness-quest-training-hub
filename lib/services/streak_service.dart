import '../database/crud/workout_log_crud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static final StreakService instance = StreakService._internal();
  StreakService._internal();

  final WorkoutLogCrud _logCrud = WorkoutLogCrud();

  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyLastWorkoutDate = 'last_workout_date';

  // ─── CALCULATE STREAK ───────────────────────────────────
  Future<int> calculateCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWorkoutDate = prefs.getString(_keyLastWorkoutDate);
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;

    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    // If no workout has ever been logged
    if (lastWorkoutDate == null) return 0;

    // If already worked out today, return current streak as is
    if (lastWorkoutDate == todayStr) return currentStreak;

    // If last workout was yesterday, streak is still alive
    if (lastWorkoutDate == yesterdayStr) return currentStreak;

    // Otherwise streak is broken — reset it
    await prefs.setInt(_keyCurrentStreak, 0);
    return 0;
  }

  // ─── LOG A WORKOUT & UPDATE STREAK ──────────────────────
  Future<void> recordWorkoutToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastWorkoutDate = prefs.getString(_keyLastWorkoutDate);

    // Don't count multiple workouts in the same day
    if (lastWorkoutDate == today) return;

    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final yesterday = _formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // If last workout was yesterday, extend streak
    if (lastWorkoutDate == yesterday) {
      currentStreak += 1;
    } else {
      // Streak was broken, start fresh
      currentStreak = 1;
    }

    // Save updated values
    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setString(_keyLastWorkoutDate, today);

    // Update longest streak if needed
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    if (currentStreak > longestStreak) {
      await prefs.setInt(_keyLongestStreak, currentStreak);
    }
  }

  // ─── GET STREAK VALUES ──────────────────────────────────
  Future<int> getCurrentStreak() async {
    return await calculateCurrentStreak();
  }

  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLongestStreak) ?? 0;
  }

  Future<String?> getLastWorkoutDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastWorkoutDate);
  }

  // ─── CHECK IF WORKED OUT TODAY ──────────────────────────
  Future<bool> hasWorkedOutToday() async {
    final logs = await _logCrud.getTodaysLogs();
    return logs.isNotEmpty;
  }

  // ─── HELPER ─────────────────────────────────────────────
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}