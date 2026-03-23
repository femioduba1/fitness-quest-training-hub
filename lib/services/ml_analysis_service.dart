import 'package:flutter/material.dart';
import '../database/crud/workout_log_crud.dart';
import '../database/crud/personal_record_crud.dart';
import '../database/crud/exercise_crud.dart';

class MLAnalysisService {
  static final MLAnalysisService instance = MLAnalysisService._internal();
  MLAnalysisService._internal();

  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final PersonalRecordCrud _prCrud = PersonalRecordCrud();
  final ExerciseCrud _exerciseCrud = ExerciseCrud();

  // ── MAIN ANALYSIS ENTRY POINT ────────────────────────────
  Future<MLAnalysisResult> analyzeAll() async {
    final logs = await _logCrud.getLogsWithExerciseNames();
    final exercises = await _exerciseCrud.getAllExercises();

    final consistency = _calculateConsistencyScore(logs);
    final volumeTrend = _calculateVolumeTrend(logs);
    final muscleBalance = _calculateMuscleBalance(logs);
    final strengthTrend = await _calculateStrengthTrend(exercises);
    final recommendations = _generateRecommendations(
      consistency: consistency,
      volumeTrend: volumeTrend,
      muscleBalance: muscleBalance,
      strengthTrend: strengthTrend,
      logs: logs,
    );

    return MLAnalysisResult(
      consistencyScore: consistency,
      volumeTrend: volumeTrend,
      muscleBalance: muscleBalance,
      strengthTrend: strengthTrend,
      recommendations: recommendations,
    );
  }

  // ── 1. CONSISTENCY SCORE (0–100) ─────────────────────────
  // Uses frequency analysis over last 30 days
  double _calculateConsistencyScore(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return 0;

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Get unique workout days in last 30 days
    final Set<String> workoutDays = {};
    for (final log in logs) {
      final date = DateTime.parse(log['logged_at']);
      if (date.isAfter(thirtyDaysAgo)) {
        workoutDays.add(
            '${date.year}-${date.month}-${date.day}');
      }
    }

    // Score = (unique days / 20 ideal days) * 100, capped at 100
    final score = (workoutDays.length / 20 * 100).clamp(0, 100);
    return score.toDouble();
  }

  // ── 2. VOLUME TREND (linear regression) ──────────────────
  // Volume = sets × reps × weight per session
  // Returns slope: positive = improving, negative = declining
  VolumeTrend _calculateVolumeTrend(List<Map<String, dynamic>> logs) {
    if (logs.length < 3) {
      return VolumeTrend(
          slope: 0, weeklyVolumes: [], trend: TrendDirection.neutral);
    }

    // Group logs by week
    final Map<int, double> weeklyVolume = {};
    for (final log in logs) {
      final date = DateTime.parse(log['logged_at']);
      final weekNumber = _weekNumber(date);
      final sets = (log['sets'] as int? ?? 1).toDouble();
      final reps = (log['reps'] as int? ?? 1).toDouble();
      final weight = (log['weight'] as double? ?? 1.0);
      final volume = sets * reps * (weight > 0 ? weight : 1);
      weeklyVolume[weekNumber] =
          (weeklyVolume[weekNumber] ?? 0) + volume;
    }

    final sortedWeeks = weeklyVolume.keys.toList()..sort();
    if (sortedWeeks.length < 2) {
      return VolumeTrend(
          slope: 0,
          weeklyVolumes: weeklyVolume.values.toList(),
          trend: TrendDirection.neutral);
    }

    // Simple linear regression
    final n = sortedWeeks.length;
    final xValues =
        List.generate(n, (i) => i.toDouble());
    final yValues =
        sortedWeeks.map((w) => weeklyVolume[w]!).toList();

    final slope = _linearRegressionSlope(xValues, yValues);

    return VolumeTrend(
      slope: slope,
      weeklyVolumes: yValues,
      trend: slope > 50
          ? TrendDirection.up
          : slope < -50
              ? TrendDirection.down
              : TrendDirection.neutral,
    );
  }

  // ── 3. MUSCLE BALANCE SCORE ───────────────────────────────
  // Detects if user is overtraining certain groups
  Map<String, double> _calculateMuscleBalance(
      List<Map<String, dynamic>> logs) {
    final Map<String, int> muscleCounts = {};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final log in logs) {
      final date = DateTime.parse(log['logged_at']);
      if (date.isAfter(thirtyDaysAgo)) {
        final muscle = log['muscle_group'] as String? ?? 'Other';
        muscleCounts[muscle] = (muscleCounts[muscle] ?? 0) + 1;
      }
    }

    // Normalize to percentages
    final total =
        muscleCounts.values.fold(0, (a, b) => a + b).toDouble();
    if (total == 0) return {};

    return muscleCounts.map(
        (k, v) => MapEntry(k, (v / total * 100).toDouble()));
  }

  // ── 4. STRENGTH TREND PER EXERCISE ───────────────────────
  Future<Map<String, double>> _calculateStrengthTrend(
      List<Map<String, dynamic>> exercises) async {
    final Map<String, double> trends = {};

    for (final exercise in exercises) {
      final records =
          await _prCrud.getRecordsForExercise(exercise['id']);
      if (records.length < 2) continue;

      final sorted = records
        ..sort((a, b) => DateTime.parse(a['achieved_at'])
            .compareTo(DateTime.parse(b['achieved_at'])));

      final values = sorted
          .map((r) => (r['record_value'] as num).toDouble())
          .toList();
      final xValues =
          List.generate(values.length, (i) => i.toDouble());
      final slope = _linearRegressionSlope(xValues, values);
      trends[exercise['name']] = slope;
    }

    return trends;
  }

  // ── 5. GENERATE RECOMMENDATIONS ──────────────────────────
  List<MLRecommendation> _generateRecommendations({
    required double consistency,
    required VolumeTrend volumeTrend,
    required Map<String, double> muscleBalance,
    required Map<String, double> strengthTrend,
    required List<Map<String, dynamic>> logs,
  }) {
    final List<MLRecommendation> recs = [];

    // Consistency recommendations
    if (consistency < 30) {
      recs.add(MLRecommendation(
        title: 'Consistency Needs Work',
        message:
            'You\'ve only worked out ${consistency.toInt()}% of your target days. Try scheduling fixed workout times each week.',
        icon: '📅',
        color: const Color(0xFFF44336),
        priority: 5,
      ));
    } else if (consistency >= 80) {
      recs.add(MLRecommendation(
        title: 'Elite Consistency!',
        message:
            'Your ${consistency.toInt()}% consistency score is exceptional. You\'re building a powerful habit.',
        icon: '🏆',
        color: const Color(0xFF4CAF50),
        priority: 1,
      ));
    }

    // Volume trend recommendations
    if (volumeTrend.trend == TrendDirection.down) {
      recs.add(MLRecommendation(
        title: 'Training Volume Declining',
        message:
            'Your weekly training volume has been dropping. Consider adding one more set per exercise or an extra session.',
        icon: '📉',
        color: const Color(0xFFF44336),
        priority: 4,
      ));
    } else if (volumeTrend.trend == TrendDirection.up) {
      recs.add(MLRecommendation(
        title: 'Volume Trending Up 🔥',
        message:
            'Your training volume is consistently increasing — a strong indicator of progressive overload.',
        icon: '📈',
        color: const Color(0xFF4CAF50),
        priority: 2,
      ));
    }

    // Muscle balance recommendations
    if (muscleBalance.isNotEmpty) {
      final sorted = muscleBalance.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dominant = sorted.first;
      final weakest = sorted.last;

      if (dominant.value > 50) {
        recs.add(MLRecommendation(
          title: '${dominant.key} Dominant',
          message:
              '${dominant.value.toInt()}% of your workouts target ${dominant.key}. Balance your training by adding more ${weakest.key} work.',
          icon: '⚖️',
          color: const Color(0xFFFF9800),
          priority: 3,
        ));
      }
    }

    // Strength trend recommendations
    final improving = strengthTrend.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();
    final declining = strengthTrend.entries
        .where((e) => e.value < 0)
        .map((e) => e.key)
        .toList();

    if (improving.isNotEmpty) {
      recs.add(MLRecommendation(
        title: 'Strength Gains Detected',
        message:
            'You\'re getting stronger in: ${improving.take(3).join(', ')}. Keep pushing progressive overload!',
        icon: '💪',
        color: const Color(0xFF4CAF50),
        priority: 2,
      ));
    }

    if (declining.isNotEmpty) {
      recs.add(MLRecommendation(
        title: 'Strength Dropping',
        message:
            'Performance declining in: ${declining.take(2).join(', ')}. Check your sleep, nutrition, and recovery.',
        icon: '⚠️',
        color: const Color(0xFFF44336),
        priority: 4,
      ));
    }

    if (recs.isEmpty) {
      recs.add(MLRecommendation(
        title: 'Keep Logging Workouts',
        message:
            'Log at least 5 workouts to unlock personalized ML-powered analysis and recommendations.',
        icon: '🤖',
        color: const Color(0xFF2196F3),
        priority: 1,
      ));
    }

    recs.sort((a, b) => b.priority.compareTo(a.priority));
    return recs;
  }

  // ── HELPERS ───────────────────────────────────────────────
  double _linearRegressionSlope(
      List<double> x, List<double> y) {
    final n = x.length;
    if (n < 2) return 0;

    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }

    return denominator == 0 ? 0 : numerator / denominator;
  }

  int _weekNumber(DateTime date) {
    return (date.difference(DateTime(date.year, 1, 1)).inDays / 7)
        .floor();
  }

  // ── CHART DATA HELPERS ────────────────────────────────────

  // Weekly workout counts for bar chart (last 8 weeks)
  Future<List<WeeklyChartData>> getWeeklyChartData() async {
    final logs = await _logCrud.getAllLogs();
    final Map<int, int> weekCounts = {};
    final now = DateTime.now();

    for (int i = 0; i < 8; i++) {
      weekCounts[i] = 0;
    }

    for (final log in logs) {
      final date = DateTime.parse(log['logged_at']);
      final weeksAgo = now.difference(date).inDays ~/ 7;
      if (weeksAgo < 8) {
        weekCounts[weeksAgo] = (weekCounts[weeksAgo] ?? 0) + 1;
      }
    }

    return List.generate(8, (i) {
      final weeksAgo = 7 - i;
      final weekStart =
          now.subtract(Duration(days: weeksAgo * 7));
      return WeeklyChartData(
        weekLabel: _weekLabel(weekStart),
        workoutCount: weekCounts[weeksAgo] ?? 0,
        weekStart: weekStart,
      );
    });
  }

  // Monthly workout counts for line chart (last 6 months)
  Future<List<MonthlyChartData>> getMonthlyChartData() async {
    final logs = await _logCrud.getAllLogs();
    final Map<String, int> monthCounts = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month =
          DateTime(now.year, now.month - i, 1);
      final key =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      monthCounts[key] = 0;
    }

    for (final log in logs) {
      final date = DateTime.parse(log['logged_at']);
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (monthCounts.containsKey(key)) {
        monthCounts[key] = (monthCounts[key] ?? 0) + 1;
      }
    }

    return monthCounts.entries.map((e) {
      final parts = e.key.split('-');
      final date =
          DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return MonthlyChartData(
        monthLabel: _monthLabel(date),
        workoutCount: e.value,
        month: date,
      );
    }).toList();
  }

  // Today's logs
  Future<List<Map<String, dynamic>>> getTodaysLogs() async {
    return await _logCrud.getLogsWithExerciseNames();
  }

  String _weekLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }
}

// ── DATA MODELS ───────────────────────────────────────────────
enum TrendDirection { up, down, neutral }

class VolumeTrend {
  final double slope;
  final List<double> weeklyVolumes;
  final TrendDirection trend;
  VolumeTrend(
      {required this.slope,
      required this.weeklyVolumes,
      required this.trend});
}

class MLAnalysisResult {
  final double consistencyScore;
  final VolumeTrend volumeTrend;
  final Map<String, double> muscleBalance;
  final Map<String, double> strengthTrend;
  final List<MLRecommendation> recommendations;

  MLAnalysisResult({
    required this.consistencyScore,
    required this.volumeTrend,
    required this.muscleBalance,
    required this.strengthTrend,
    required this.recommendations,
  });
}

class MLRecommendation {
  final String title;
  final String message;
  final String icon;
  final Color color;
  final int priority;

  MLRecommendation({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

class WeeklyChartData {
  final String weekLabel;
  final int workoutCount;
  final DateTime weekStart;
  WeeklyChartData(
      {required this.weekLabel,
      required this.workoutCount,
      required this.weekStart});
}

class MonthlyChartData {
  final String monthLabel;
  final int workoutCount;
  final DateTime month;
  MonthlyChartData(
      {required this.monthLabel,
      required this.workoutCount,
      required this.month});
}