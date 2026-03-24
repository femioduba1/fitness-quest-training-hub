import '../services/preferences_service.dart';

/// Generates personalized quest suggestions based on
/// user's onboarding profile — fitness goal, experience
/// level and preferred workout frequency
class QuestSuggestionService {
  static final QuestSuggestionService instance =
      QuestSuggestionService._internal();
  QuestSuggestionService._internal();

  final PreferencesService _prefs =
      PreferencesService.instance;

  /// Returns a list of suggested quests tailored to the user
  Future<List<QuestSuggestion>> getSuggestions() async {
    final goal = await _prefs.getFitnessGoal();
    final level = await _prefs.getExperienceLevel();
    final frequency = await _prefs.getWorkoutFrequency();
    final name = await _prefs.getUserName();

    final List<QuestSuggestion> suggestions = [];

    // Add goal-based suggestions
    suggestions
        .addAll(_getGoalBasedSuggestions(goal, level));

    // Add level-based suggestions
    suggestions.addAll(
        _getLevelBasedSuggestions(level, frequency));

    // Add frequency-based suggestions
    suggestions.addAll(
        _getFrequencyBasedSuggestions(frequency));

    // Add college student specific suggestions
    suggestions.addAll(_getCollegeStudentSuggestions());

    // Remove duplicates and return top 6
    final seen = <String>{};
    final unique = suggestions
        .where((s) => seen.add(s.name))
        .toList();

    return unique.take(6).toList();
  }

  /// Suggests quests based on fitness goal
  List<QuestSuggestion> _getGoalBasedSuggestions(
      String goal, String level) {
    switch (goal) {
      case 'build_muscle':
        return [
          QuestSuggestion(
            name: 'Mass Builder Challenge',
            description:
                'Progressive overload program designed to maximize muscle hypertrophy with compound lifts.',
            icon: '💪',
            color: 0xFFFF6000,
            durationWeeks: 4,
            weeklyGoal: 4,
            exercises: [
              'Bench Press',
              'Deadlift',
              'Squat',
              'Bent Over Row',
              'Overhead Press'
            ],
            reason:
                'Based on your muscle building goal — heavy compound movements for maximum gains',
          ),
          QuestSuggestion(
            name: 'Hypertrophy Sprint',
            description:
                'High volume training targeting all major muscle groups for size and definition.',
            icon: '🏋️',
            color: 0xFFFF6000,
            durationWeeks: 2,
            weeklyGoal: 5,
            exercises: [
              'Incline Bench Press',
              'Pull-Up',
              'Leg Press',
              'Bicep Curl',
              'Lateral Raise'
            ],
            reason:
                'High volume approach — ideal for building muscle quickly',
          ),
        ];

      case 'lose_weight':
        return [
          QuestSuggestion(
            name: 'Fat Burn Circuit',
            description:
                'High intensity workouts combining strength and cardio to maximize calorie burn.',
            icon: '🔥',
            color: 0xFFF44336,
            durationWeeks: 4,
            weeklyGoal: 5,
            exercises: [
              'Mountain Climbers',
              'Squat',
              'Push-Up',
              'Lunges',
              'Plank'
            ],
            reason:
                'Based on your weight loss goal — burns maximum calories while preserving muscle',
          ),
          QuestSuggestion(
            name: '30-Day Lean Challenge',
            description:
                'Full body workouts every other day to build a calorie-burning metabolism.',
            icon: '⚡',
            color: 0xFFF44336,
            durationWeeks: 4,
            weeklyGoal: 4,
            exercises: [
              'Bicycle Crunches',
              'Bulgarian Split Squat',
              'Push-Up',
              'Mountain Climbers',
              'Russian Twist'
            ],
            reason:
                'Full body approach maximizes fat burning for your weight loss goal',
          ),
        ];

      case 'get_fit':
        return [
          QuestSuggestion(
            name: 'Total Fitness Quest',
            description:
                'Well-rounded program hitting all fitness components — strength, endurance and flexibility.',
            icon: '⚡',
            color: 0xFF2196F3,
            durationWeeks: 4,
            weeklyGoal: 3,
            exercises: [
              'Squat',
              'Push-Up',
              'Pull-Up',
              'Plank',
              'Lunges'
            ],
            reason:
                'Balanced program for your overall fitness goal',
          ),
        ];

      case 'strength':
        return [
          QuestSuggestion(
            name: 'Strength Foundation',
            description:
                'Powerlifting-inspired program focused on the big three lifts for raw strength.',
            icon: '🏋️',
            color: 0xFF9C27B0,
            durationWeeks: 4,
            weeklyGoal: 4,
            exercises: [
              'Deadlift',
              'Squat',
              'Bench Press',
              'Overhead Press',
              'Bent Over Row'
            ],
            reason:
                'Heavy compound lifts aligned with your strength goal',
          ),
        ];

      case 'endurance':
        return [
          QuestSuggestion(
            name: 'Endurance Builder',
            description:
                'High rep, low rest program to build muscular and cardiovascular endurance.',
            icon: '🏃',
            color: 0xFF4CAF50,
            durationWeeks: 4,
            weeklyGoal: 5,
            exercises: [
              'Mountain Climbers',
              'Lunges',
              'Push-Up',
              'Plank',
              'Bicycle Crunches'
            ],
            reason:
                'High volume bodyweight work aligned with your endurance goal',
          ),
        ];

      case 'stay_active':
        return [
          QuestSuggestion(
            name: 'Active Lifestyle Quest',
            description:
                'Low pressure program to build the habit of regular movement without burning out.',
            icon: '🌟',
            color: 0xFFFF9800,
            durationWeeks: 2,
            weeklyGoal: 3,
            exercises: [
              'Push-Up',
              'Plank',
              'Squat',
              'Lunges',
              'Crunches'
            ],
            reason:
                'Light and sustainable — perfect for staying consistently active',
          ),
        ];

      default:
        return [];
    }
  }

  /// Suggests quests based on experience level
  List<QuestSuggestion> _getLevelBasedSuggestions(
      String level, int frequency) {
    switch (level) {
      case 'beginner':
        return [
          QuestSuggestion(
            name: 'Beginner Bootcamp',
            description:
                'Perfect starting point — bodyweight exercises that build a solid foundation without equipment.',
            icon: '🌱',
            color: 0xFF4CAF50,
            durationWeeks: 2,
            weeklyGoal: 3,
            exercises: [
              'Push-Up',
              'Squat',
              'Plank',
              'Lunges',
              'Crunches'
            ],
            reason:
                'Tailored for beginners — no equipment needed, builds solid habits',
          ),
          QuestSuggestion(
            name: '2-Week Kickstart',
            description:
                'A short, achievable challenge to get your body moving and build confidence.',
            icon: '🚀',
            color: 0xFF4CAF50,
            durationWeeks: 2,
            weeklyGoal: 2,
            exercises: [
              'Push-Up',
              'Plank',
              'Squat',
              'Crunches',
              'Lunges'
            ],
            reason:
                'Short duration makes it easy to complete as a beginner',
          ),
        ];

      case 'intermediate':
        return [
          QuestSuggestion(
            name: 'Intermediate Power Month',
            description:
                'Mix of compound and isolation exercises to break through plateaus.',
            icon: '📈',
            color: 0xFFFFC107,
            durationWeeks: 4,
            weeklyGoal: 4,
            exercises: [
              'Bench Press',
              'Bent Over Row',
              'Squat',
              'Overhead Press',
              'Bicep Curl'
            ],
            reason:
                'Intermediate program to keep you progressing past your current level',
          ),
        ];

      case 'advanced':
        return [
          QuestSuggestion(
            name: 'Advanced Elite Program',
            description:
                'High intensity, high volume training for experienced athletes chasing peak performance.',
            icon: '🏆',
            color: 0xFFF44336,
            durationWeeks: 4,
            weeklyGoal: 6,
            exercises: [
              'Deadlift',
              'Squat',
              'Bench Press',
              'Pull-Up',
              'Overhead Press'
            ],
            reason:
                'Advanced compound program for athletes who are ready for maximum intensity',
          ),
        ];

      default:
        return [];
    }
  }

  /// Suggests quests based on preferred frequency
  List<QuestSuggestion> _getFrequencyBasedSuggestions(
      int frequency) {
    if (frequency <= 2) {
      return [
        QuestSuggestion(
          name: 'Minimal Effective Dose',
          description:
              'Just 2 sessions per week — each session is full body to maximize your limited gym time.',
          icon: '⏱️',
          color: 0xFF2196F3,
          durationWeeks: 4,
          weeklyGoal: 2,
          exercises: [
            'Deadlift',
            'Bench Press',
            'Squat',
            'Pull-Up',
            'Plank'
          ],
          reason:
              'Designed for your ${frequency}x per week schedule — maximum results with minimum sessions',
        ),
      ];
    } else if (frequency <= 4) {
      return [
        QuestSuggestion(
          name: 'Consistent 4-Day Split',
          description:
              'Upper/lower split across 4 days with optimal rest for recovery and growth.',
          icon: '📅',
          color: 0xFF2196F3,
          durationWeeks: 4,
          weeklyGoal: 4,
          exercises: [
            'Bench Press',
            'Bent Over Row',
            'Squat',
            'Romanian Deadlift',
            'Overhead Press'
          ],
          reason:
              'Matches your ${frequency}x/week preference with structured recovery days',
        ),
      ];
    } else {
      return [
        QuestSuggestion(
          name: 'High Frequency Warrior',
          description:
              'Train 5-6 days per week with rotating muscle groups for maximum weekly volume.',
          icon: '🔥',
          color: 0xFFF44336,
          durationWeeks: 4,
          weeklyGoal: frequency,
          exercises: [
            'Bench Press',
            'Pull-Up',
            'Squat',
            'Overhead Press',
            'Deadlift'
          ],
          reason:
              'High frequency program matching your ambitious ${frequency}x/week goal',
        ),
      ];
    }
  }

  /// College student specific quest suggestions
  List<QuestSuggestion> _getCollegeStudentSuggestions() {
    return [
      QuestSuggestion(
        name: 'Dorm Room Warrior',
        description:
            'No gym? No problem. Complete this quest entirely in your dorm room with zero equipment.',
        icon: '🏠',
        color: 0xFF9C27B0,
        durationWeeks: 2,
        weeklyGoal: 3,
        exercises: [
          'Push-Up',
          'Plank',
          'Squat',
          'Lunges',
          'Mountain Climbers',
          'Bicycle Crunches',
          'Wide Push-Up',
          'Side Plank',
          'Crunches',
          'Dead Bug'
        ],
        reason:
            'No equipment needed — perfect for dorm rooms or home workouts between classes',
      ),
      QuestSuggestion(
        name: 'Finals Week Survival',
        description:
            'Short 20-minute sessions to keep your body active and your mind sharp during exam season.',
        icon: '📚',
        color: 0xFF4CAF50,
        durationWeeks: 1,
        weeklyGoal: 3,
        exercises: [
          'Plank',
          'Push-Up',
          'Squat',
          'Crunches',
          'Lunges'
        ],
        reason:
            'Designed for busy college students — short sessions that reduce stress and boost focus',
      ),
    ];
  }
}

/// A single quest suggestion with all data needed to create it
class QuestSuggestion {
  final String name;
  final String description;
  final String icon;
  final int color;
  final int durationWeeks;
  final int weeklyGoal;
  final List<String> exercises;
  final String reason;

  QuestSuggestion({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.durationWeeks,
    required this.weeklyGoal,
    required this.exercises,
    required this.reason,
  });
}