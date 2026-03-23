import '../database/crud/workout_log_crud.dart';
import '../database/crud/quest_crud.dart';
import '../services/streak_service.dart';
import 'package:flutter/material.dart';

class AITrainerService {
  static final AITrainerService instance = AITrainerService._internal();
  AITrainerService._internal();

  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final QuestCrud _questCrud = QuestCrud();
  final StreakService _streakService = StreakService.instance;

  // ── MUSCLE GROUP RECOVERY RULES ──────────────────────────
  // How many days each muscle group needs to recover
  static const Map<String, int> _recoveryDays = {
    'Chest': 2,
    'Back': 2,
    'Legs': 3,
    'Core': 1,
    'Arms': 1,
    'Shoulders': 2,
  };

  // ── MOTIVATIONAL QUOTES ──────────────────────────────────
  static const List<Map<String, String>> motivationalQuotes = [
    {
      'quote': 'The last three or four reps is what makes the muscle grow.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': 'If you want something you\'ve never had, you must be willing to do something you\'ve never done.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': 'You shall gain, but you shall pay with sweat, blood, and vomit.',
      'author': 'Pavel Tsatsouline',
    },
    {
      'quote': 'The pain you feel today will be the strength you feel tomorrow.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': 'No citizen has a right to be an amateur in the matter of physical training.',
      'author': 'Socrates',
    },
    {
      'quote': 'Strength does not come from the physical capacity. It comes from an indomitable will.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The body achieves what the mind believes.',
      'author': 'Napoleon Hill',
    },
    {
      'quote': 'You have to think it before you can do it. The mind is what makes it all possible.',
      'author': 'Kai Greene',
    },
    {
      'quote': 'Everybody wants to be a bodybuilder, but nobody wants to lift no heavy-ass weights.',
      'author': 'Ronnie Coleman',
    },
    {
      'quote': 'Ain\'t nothing but a peanut.',
      'author': 'Ronnie Coleman',
    },
    {
      'quote': 'I do it as a therapy. I do it as something that makes me feel good.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': 'The road to nowhere is paved with excuses.',
      'author': 'Mark Bell',
    },
  ];

  // ── GET ALL RECOMMENDATIONS ──────────────────────────────
  Future<List<AIRecommendation>> getRecommendations() async {
    final List<AIRecommendation> recommendations = [];

    final muscleRec = await _getMuscleGroupRecommendation();
    if (muscleRec != null) recommendations.add(muscleRec);

    final overworkRec = await _getOverworkWarnings();
    recommendations.addAll(overworkRec);

    final restRec = await _getRestDayRecommendation();
    if (restRec != null) recommendations.add(restRec);

    final goalRec = await _getWeeklyGoalNudge();
    if (goalRec != null) recommendations.add(goalRec);

    // If nothing to show, add a default motivational tip
    if (recommendations.isEmpty) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.tip,
        title: 'Ready to Train!',
        message: 'All muscle groups are recovered. Pick any exercise and get after it!',
        icon: '💪',
        priority: 0,
      ));
    }

    // Sort by priority — highest first
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }

  // ── RULE 1: SUGGEST MUSCLE GROUP ─────────────────────────
  Future<AIRecommendation?> _getMuscleGroupRecommendation() async {
    final logs = await _logCrud.getLogsWithExerciseNames();
    final now = DateTime.now();

    // Find which muscle groups were recently trained
    final Map<String, DateTime> lastTrained = {};
    for (final log in logs) {
      final muscleGroup = log['muscle_group'] as String? ?? '';
      final loggedAt = DateTime.parse(log['logged_at']);
      if (!lastTrained.containsKey(muscleGroup) ||
          loggedAt.isAfter(lastTrained[muscleGroup]!)) {
        lastTrained[muscleGroup] = loggedAt;
      }
    }

    // Find muscle groups ready to train
    final List<String> readyMuscles = [];
    for (final entry in _recoveryDays.entries) {
      final muscle = entry.key;
      final recovery = entry.value;
      if (!lastTrained.containsKey(muscle)) {
        readyMuscles.add(muscle); // Never trained
      } else {
        final daysSince =
            now.difference(lastTrained[muscle]!).inDays;
        if (daysSince >= recovery) {
          readyMuscles.add(muscle);
        }
      }
    }

    if (readyMuscles.isEmpty) return null;

    // Prioritize muscles not trained recently
    readyMuscles.sort((a, b) {
      final aDate = lastTrained[a] ?? DateTime(2000);
      final bDate = lastTrained[b] ?? DateTime(2000);
      return aDate.compareTo(bDate); // Oldest first
    });

    final suggested = readyMuscles.first;
    return AIRecommendation(
      type: RecommendationType.suggestion,
      title: 'Train $suggested Today',
      message:
          'Your $suggested muscles are fully recovered and ready to be pushed. Time to hit them hard!',
      icon: '🎯',
      priority: 3,
    );
  }

  // ── RULE 2: OVERWORK WARNING ─────────────────────────────
  Future<List<AIRecommendation>> _getOverworkWarnings() async {
    final logs = await _logCrud.getLogsWithExerciseNames();
    final now = DateTime.now();
    final List<AIRecommendation> warnings = [];

    final Map<String, int> recentCount = {};
    for (final log in logs) {
      final muscle = log['muscle_group'] as String? ?? '';
      final loggedAt = DateTime.parse(log['logged_at']);
      final daysSince = now.difference(loggedAt).inDays;

      if (daysSince <= 2) {
        recentCount[muscle] = (recentCount[muscle] ?? 0) + 1;
      }
    }

    for (final entry in recentCount.entries) {
      if (entry.value >= 3) {
        warnings.add(AIRecommendation(
          type: RecommendationType.warning,
          title: '${entry.key} Overworked!',
          message:
              'You\'ve trained ${entry.key} ${entry.value} times in the last 2 days. Rest it to avoid injury and allow growth.',
          icon: '⚠️',
          priority: 5,
        ));
      }
    }

    return warnings;
  }

  // ── RULE 3: REST DAY RECOMMENDATION ─────────────────────
  Future<AIRecommendation?> _getRestDayRecommendation() async {
    final streak = await _streakService.getCurrentStreak();

    if (streak >= 6) {
      return AIRecommendation(
        type: RecommendationType.rest,
        title: 'Rest Day Recommended',
        message:
            'You\'ve trained $streak days in a row. Elite athletes take rest days too — recovery is where the gains happen.',
        icon: '😴',
        priority: 4,
      );
    }

    if (streak >= 4) {
      return AIRecommendation(
        type: RecommendationType.rest,
        title: 'Consider Active Recovery',
        message:
            '$streak days straight — great work! Consider a light stretching or mobility session today instead of heavy lifting.',
        icon: '🧘',
        priority: 2,
      );
    }

    return null;
  }

  // ── RULE 4: WEEKLY GOAL NUDGE ────────────────────────────
  Future<AIRecommendation?> _getWeeklyGoalNudge() async {
    final quests = await _questCrud.getActiveQuests();
    if (quests.isEmpty) return null;

    final quest = quests.first;
    final weeklyGoal = quest['weekly_goal'] as int;
    final weeklyCount = await _logCrud.getWeeklyWorkoutCount();
    final remaining = weeklyGoal - weeklyCount;

    if (remaining <= 0) {
      return AIRecommendation(
        type: RecommendationType.tip,
        title: 'Weekly Goal Crushed! 🎉',
        message:
            'You\'ve hit your goal of $weeklyGoal workouts this week. Every extra session is a bonus — keep pushing!',
        icon: '🏆',
        priority: 1,
      );
    }

    // Check how many days left in the week
    final daysLeftInWeek = 7 - DateTime.now().weekday;

    if (remaining > daysLeftInWeek) {
      return AIRecommendation(
        type: RecommendationType.warning,
        title: 'Behind on Weekly Goal',
        message:
            'You need $remaining more workouts but only $daysLeftInWeek days left this week. Time to pick it up!',
        icon: '📅',
        priority: 4,
      );
    }

    return AIRecommendation(
      type: RecommendationType.tip,
      title: '$remaining Workouts Left This Week',
      message:
          'You\'re on track! $remaining more sessions to hit your goal of $weeklyGoal workouts.',
      icon: '📈',
      priority: 1,
    );
  }

  // ── GET DAILY QUOTE ──────────────────────────────────────
  Map<String, String> getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return motivationalQuotes[dayOfYear % motivationalQuotes.length];
  }

  // ── GET RANDOM QUOTE ─────────────────────────────────────
  Map<String, String> getRandomQuote() {
    final index = DateTime.now().millisecondsSinceEpoch %
        motivationalQuotes.length;
    return motivationalQuotes[index];
  }
}

// ── DATA MODELS ──────────────────────────────────────────────
enum RecommendationType { suggestion, warning, rest, tip }

class AIRecommendation {
  final RecommendationType type;
  final String title;
  final String message;
  final String icon;
  final int priority;

  AIRecommendation({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.priority,
  });

  Color get color {
    switch (type) {
      case RecommendationType.warning:
        return Color(0xFFF44336);
      case RecommendationType.rest:
        return Color(0xFF2196F3);
      case RecommendationType.suggestion:
        return Color(0xFFFF6000);
      case RecommendationType.tip:
        return Color(0xFF4CAF50);
    }
  }
}