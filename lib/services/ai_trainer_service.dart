import 'package:flutter/material.dart';
import '../database/crud/workout_log_crud.dart';
import '../database/crud/quest_crud.dart';
import '../services/streak_service.dart';

/// Rule-based AI Trainer that analyzes workout history and provides
/// personalized recommendations without any external API.
/// All logic runs locally on-device using SQLite data.
class AITrainerService {
  static final AITrainerService instance =
      AITrainerService._internal();
  AITrainerService._internal();

  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final QuestCrud _questCrud = QuestCrud();
  final StreakService _streakService = StreakService.instance;

  /// How many days each muscle group needs to recover before training again
  static const Map<String, int> _recoveryDays = {
    'Chest': 2,
    'Back': 2,
    'Legs': 3,
    'Core': 1,
    'Arms': 1,
    'Shoulders': 2,
  };

  /// Motivational quotes from professional bodybuilders and athletes
  /// Rotated daily and sent as push notifications
  static const List<Map<String, String>> motivationalQuotes = [
    {
      'quote':
          'The last three or four reps is what makes the muscle grow.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote':
          'If you want something you\'ve never had, you must be willing to do something you\'ve never done.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote':
          'You shall gain, but you shall pay with sweat, blood, and vomit.',
      'author': 'Pavel Tsatsouline',
    },
    {
      'quote':
          'The pain you feel today will be the strength you feel tomorrow.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote':
          'No citizen has a right to be an amateur in the matter of physical training.',
      'author': 'Socrates',
    },
    {
      'quote':
          'Strength does not come from the physical capacity. It comes from an indomitable will.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The body achieves what the mind believes.',
      'author': 'Napoleon Hill',
    },
    {
      'quote':
          'You have to think it before you can do it. The mind is what makes it all possible.',
      'author': 'Kai Greene',
    },
    {
      'quote':
          'Everybody wants to be a bodybuilder, but nobody wants to lift no heavy-ass weights.',
      'author': 'Ronnie Coleman',
    },
    {
      'quote': 'Ain\'t nothing but a peanut.',
      'author': 'Ronnie Coleman',
    },
    {
      'quote':
          'I do it as a therapy. I do it as something that makes me feel good.',
      'author': 'Arnold Schwarzenegger',
    },
    {
      'quote': 'The road to nowhere is paved with excuses.',
      'author': 'Mark Bell',
    },
  ];

  // ── MAIN ENTRY POINT ─────────────────────────────────────

  /// Runs all 4 analysis rules in parallel and returns a
  /// priority-sorted list of recommendations for the user
  Future<List<AIRecommendation>> getRecommendations() async {
    final List<AIRecommendation> recommendations = [];

    // Run each rule independently
    final muscleRec = await _getMuscleGroupRecommendation();
    if (muscleRec != null) recommendations.add(muscleRec);

    final overworkRecs = await _getOverworkWarnings();
    recommendations.addAll(overworkRecs);

    final restRec = await _getRestDayRecommendation();
    if (restRec != null) recommendations.add(restRec);

    final goalRec = await _getWeeklyGoalNudge();
    if (goalRec != null) recommendations.add(goalRec);

    // If no rules fired, show a default motivational tip
    if (recommendations.isEmpty) {
      recommendations.add(AIRecommendation(
        type: RecommendationType.tip,
        title: 'Ready to Train!',
        message:
            'All muscle groups are recovered. Pick any exercise and get after it!',
        icon: '💪',
        priority: 0,
      ));
    }

    // Sort by priority — highest first so most urgent shows at top
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }

  // ── RULE 1: MUSCLE GROUP SUGGESTION ──────────────────────

  /// Finds the muscle group that has been resting the longest
  /// and is fully recovered based on the recovery days map.
  /// Returns a suggestion to train that muscle group today.
  Future<AIRecommendation?> _getMuscleGroupRecommendation() async {
    final logs = await _logCrud.getLogsWithExerciseNames();
    final now = DateTime.now();

    // Build a map of muscle group → most recent training date
    final Map<String, DateTime> lastTrained = {};
    for (final log in logs) {
      final muscleGroup = log['muscle_group'] as String? ?? '';
      final loggedAt = DateTime.parse(log['logged_at']);
      if (!lastTrained.containsKey(muscleGroup) ||
          loggedAt.isAfter(lastTrained[muscleGroup]!)) {
        lastTrained[muscleGroup] = loggedAt;
      }
    }

    // Find all muscle groups that have recovered
    final List<String> readyMuscles = [];
    for (final entry in _recoveryDays.entries) {
      final muscle = entry.key;
      final recovery = entry.value;

      if (!lastTrained.containsKey(muscle)) {
        // Never trained — definitely ready
        readyMuscles.add(muscle);
      } else {
        final daysSince =
            now.difference(lastTrained[muscle]!).inDays;
        if (daysSince >= recovery) {
          readyMuscles.add(muscle);
        }
      }
    }

    if (readyMuscles.isEmpty) return null;

    // Prioritize the muscle group that has been resting the longest
    readyMuscles.sort((a, b) {
      final aDate = lastTrained[a] ?? DateTime(2000);
      final bDate = lastTrained[b] ?? DateTime(2000);
      return aDate.compareTo(bDate);
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

  // ── RULE 2: OVERWORK DETECTION ────────────────────────────

  /// Detects if any muscle group has been trained 3+ times
  /// in the last 2 days, which can lead to overtraining and injury.
  /// Returns a warning for each overworked muscle group found.
  Future<List<AIRecommendation>> _getOverworkWarnings() async {
    final logs = await _logCrud.getLogsWithExerciseNames();
    final now = DateTime.now();
    final List<AIRecommendation> warnings = [];

    // Count how many times each muscle was trained in last 2 days
    final Map<String, int> recentCount = {};
    for (final log in logs) {
      final muscle = log['muscle_group'] as String? ?? '';
      final loggedAt = DateTime.parse(log['logged_at']);
      final daysSince = now.difference(loggedAt).inDays;

      if (daysSince <= 2) {
        recentCount[muscle] = (recentCount[muscle] ?? 0) + 1;
      }
    }

    // Flag any muscle trained 3 or more times in 2 days
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

  // ── RULE 3: REST DAY RECOMMENDATION ──────────────────────

  /// Recommends rest or active recovery based on current streak length.
  /// 6+ days → full rest recommended
  /// 4–5 days → light/active recovery suggested
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

  // ── RULE 4: WEEKLY GOAL NUDGE ─────────────────────────────

  /// Compares current weekly workout count against the active quest goal.
  /// Warns if user is behind pace, celebrates if goal is already met.
  Future<AIRecommendation?> _getWeeklyGoalNudge() async {
    final quests = await _questCrud.getActiveQuests();
    if (quests.isEmpty) return null;

    // Use the most recently created active quest
    final quest = quests.first;
    final weeklyGoal = quest['weekly_goal'] as int;
    final weeklyCount = await _logCrud.getWeeklyWorkoutCount();
    final remaining = weeklyGoal - weeklyCount;

    // Goal already met this week
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

    // Check if there are enough days left to reach the goal
    final daysLeftInWeek = 7 - DateTime.now().weekday;

    if (remaining > daysLeftInWeek) {
      // Behind pace — urgent warning
      return AIRecommendation(
        type: RecommendationType.warning,
        title: 'Behind on Weekly Goal',
        message:
            'You need $remaining more workouts but only $daysLeftInWeek days left this week. Time to pick it up!',
        icon: '📅',
        priority: 4,
      );
    }

    // On track — informational nudge
    return AIRecommendation(
      type: RecommendationType.tip,
      title: '$remaining Workouts Left This Week',
      message:
          'You\'re on track! $remaining more sessions to hit your goal of $weeklyGoal workouts.',
      icon: '📈',
      priority: 1,
    );
  }

  // ── QUOTE HELPERS ─────────────────────────────────────────

  /// Returns a quote based on the day of year so it changes daily
  Map<String, String> getDailyQuote() {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return motivationalQuotes[
        dayOfYear % motivationalQuotes.length];
  }

  /// Returns a pseudo-random quote based on current milliseconds
  Map<String, String> getRandomQuote() {
    final index = DateTime.now().millisecondsSinceEpoch %
        motivationalQuotes.length;
    return motivationalQuotes[index];
  }
}

// ── DATA MODELS ───────────────────────────────────────────────

/// The 4 types of recommendations the AI Trainer can generate
enum RecommendationType {
  suggestion, // Positive action to take
  warning,    // Something to avoid
  rest,       // Recovery recommendation
  tip,        // General motivational info
}

/// A single AI recommendation with display properties
class AIRecommendation {
  final RecommendationType type;
  final String title;
  final String message;
  final String icon;

  /// Higher priority recommendations appear first in the list
  final int priority;

  AIRecommendation({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.priority,
  });

  /// Returns the color associated with this recommendation type
  /// Used for card border and icon background tinting
  Color get color {
    switch (type) {
      case RecommendationType.warning:
        return const Color(0xFFF44336); // Red
      case RecommendationType.rest:
        return const Color(0xFF2196F3); // Blue
      case RecommendationType.suggestion:
        return const Color(0xFFFF6000); // Orange
      case RecommendationType.tip:
        return const Color(0xFF4CAF50); // Green
    }
  }
}