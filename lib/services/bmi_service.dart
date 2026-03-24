import 'package:flutter/material.dart';
import '../database/crud/body_measurement_crud.dart';
import 'preferences_service.dart';

/// BMI calculation, categorization and goal tracking service
/// Calculates BMI, determines progress toward fitness goals,
/// and generates split suggestions every 2 weeks
class BMIService {
  static final BMIService instance = BMIService._internal();
  BMIService._internal();

  final BodyMeasurementCrud _crud = BodyMeasurementCrud();
  final PreferencesService _prefs =
      PreferencesService.instance;

  // ── BMI CALCULATION ───────────────────────────────────

  /// Calculates BMI from weight in kg and height in cm
  double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Returns BMI category label
  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Returns color for BMI category
  Color getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF2196F3);
    if (bmi < 25.0) return const Color(0xFF4CAF50);
    if (bmi < 30.0) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  /// Returns target BMI range based on fitness goal
  Map<String, double> getTargetBMIRange(String goal) {
    switch (goal) {
      case 'build_muscle':
        return {'min': 22.0, 'max': 27.0};
      case 'lose_weight':
        return {'min': 18.5, 'max': 24.9};
      case 'get_fit':
        return {'min': 18.5, 'max': 24.9};
      case 'strength':
        return {'min': 23.0, 'max': 28.0};
      case 'endurance':
        return {'min': 18.5, 'max': 23.0};
      case 'stay_active':
        return {'min': 18.5, 'max': 24.9};
      default:
        return {'min': 18.5, 'max': 24.9};
    }
  }

  /// Determines if user is moving toward or away from goal
  /// Returns positive = toward goal, negative = away from goal
  Future<BMIProgressResult> getBMIProgress() async {
    final measurements =
        await _crud.getLastMonthMeasurements();
    final goal = await _prefs.getFitnessGoal();

    if (measurements.length < 2) {
      return BMIProgressResult(
        direction: ProgressDirection.neutral,
        message: 'Log more measurements to see your progress trend',
        percentage: 0,
        currentBMI: measurements.isNotEmpty
            ? measurements.last['bmi']
            : 0,
        targetRange: getTargetBMIRange(goal),
      );
    }

    final firstBMI =
        measurements.first['bmi'] as double;
    final latestBMI =
        measurements.last['bmi'] as double;
    final targetRange = getTargetBMIRange(goal);
    final targetMin = targetRange['min']!;
    final targetMax = targetRange['max']!;

    // Calculate if moving toward target range
    final wasInRange =
        firstBMI >= targetMin && firstBMI <= targetMax;
    final isInRange =
        latestBMI >= targetMin && latestBMI <= targetMax;

    // Distance from target range
    double firstDistance = 0;
    double latestDistance = 0;

    if (firstBMI < targetMin) {
      firstDistance = targetMin - firstBMI;
    } else if (firstBMI > targetMax) {
      firstDistance = firstBMI - targetMax;
    }

    if (latestBMI < targetMin) {
      latestDistance = targetMin - latestBMI;
    } else if (latestBMI > targetMax) {
      latestDistance = latestBMI - targetMax;
    }

    // Determine direction
    ProgressDirection direction;
    String message;
    double percentage = 0;

    if (isInRange) {
      direction = ProgressDirection.onTrack;
      message = _getOnTrackMessage(goal, latestBMI);
      percentage = 100;
    } else if (latestDistance < firstDistance) {
      direction = ProgressDirection.improving;
      final improvement = firstDistance - latestDistance;
      percentage =
          ((improvement / firstDistance) * 100).clamp(0, 99);
      message = _getImprovingMessage(
          goal, latestBMI, percentage);
    } else {
      direction = ProgressDirection.movingAway;
      message = _getMovingAwayMessage(goal, latestBMI);
      percentage = 0;
    }

    return BMIProgressResult(
      direction: direction,
      message: message,
      percentage: percentage,
      currentBMI: latestBMI,
      targetRange: targetRange,
    );
  }

  // ── WORKOUT SPLIT SUGGESTIONS ─────────────────────────

  /// Generates split suggestions based on 2-week progress
  /// Called every 2 weeks based on quest start date
  Future<SplitSuggestion?> getBiWeeklySuggestion() async {
    final goal = await _prefs.getFitnessGoal();
    final level = await _prefs.getExperienceLevel();
    final measurements =
        await _crud.getLastMonthMeasurements();

    if (measurements.length < 2) return null;

    final latestBMI =
        measurements.last['bmi'] as double;
    final targetRange = getTargetBMIRange(goal);
    final inRange = latestBMI >= targetRange['min']! &&
        latestBMI <= targetRange['max']!;

    return _generateSplitSuggestion(
        goal, level, latestBMI, inRange);
  }

  SplitSuggestion _generateSplitSuggestion(
    String goal,
    String level,
    double bmi,
    bool inRange,
  ) {
    if (goal == 'lose_weight' && !inRange && bmi > 25) {
      return SplitSuggestion(
        title: '🔥 Increase Cardio Frequency',
        message:
            'Your BMI suggests you\'re still above target. Consider adding a 4th cardio session this week — Mountain Climbers, Bicycle Crunches, and Lunges circuits work great.',
        exercises: [
          'Mountain Climbers',
          'Bicycle Crunches',
          'Lunges',
          'Plank',
          'Squat'
        ],
        weeklyGoal: 5,
      );
    }

    if (goal == 'build_muscle' && inRange) {
      return SplitSuggestion(
        title: '💪 Progress to Heavier Compounds',
        message:
            'You\'re in your target BMI range — time to push heavier weights. Focus on progressive overload with the big 4 lifts this cycle.',
        exercises: [
          'Deadlift',
          'Bench Press',
          'Squat',
          'Overhead Press',
          'Bent Over Row'
        ],
        weeklyGoal: 4,
      );
    }

    if (goal == 'get_fit' && !inRange) {
      return SplitSuggestion(
        title: '⚡ Switch to Full Body Training',
        message:
            'Full body sessions 3x per week will help balance your fitness and move your BMI toward the healthy range faster.',
        exercises: [
          'Squat',
          'Push-Up',
          'Pull-Up',
          'Plank',
          'Lunges'
        ],
        weeklyGoal: 3,
      );
    }

    if (level == 'beginner' && bmi < 18.5) {
      return SplitSuggestion(
        title: '🌱 Add More Volume',
        message:
            'Your BMI is below the normal range. Focus on compound lifts and add an extra set to each exercise to build mass.',
        exercises: [
          'Squat',
          'Bench Press',
          'Deadlift',
          'Bicep Curl',
          'Overhead Press'
        ],
        weeklyGoal: 4,
      );
    }

    // Default maintenance suggestion
    return SplitSuggestion(
      title: '✅ Keep Your Current Split',
      message:
          'Your progress is on track! Continue your current workout plan and focus on increasing weights gradually.',
      exercises: [],
      weeklyGoal: 0,
    );
  }

  // ── LOG MEASUREMENT ───────────────────────────────────

  /// Logs a new weight measurement and calculates BMI
  Future<void> logWeight({
    required double weightKg,
    String? notes,
  }) async {
    final heightCm = await _prefs.getHeightCm();
    if (heightCm <= 0) return;

    final bmi = calculateBMI(weightKg, heightCm);
    await _crud.insertMeasurement({
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'bmi': bmi,
      'notes': notes ?? '',
    });
  }

  // ── PRIVATE HELPERS ───────────────────────────────────

  String _getOnTrackMessage(String goal, double bmi) {
    switch (goal) {
      case 'build_muscle':
        return 'BMI ${bmi.toStringAsFixed(1)} — Perfect range for muscle building! Keep lifting heavy.';
      case 'lose_weight':
        return 'BMI ${bmi.toStringAsFixed(1)} — You\'ve reached a healthy weight! Maintain with consistent training.';
      default:
        return 'BMI ${bmi.toStringAsFixed(1)} — You\'re right on target. Keep it up!';
    }
  }

  String _getImprovingMessage(
      String goal, double bmi, double pct) {
    return 'BMI ${bmi.toStringAsFixed(1)} — Moving toward your ${_goalLabel(goal)} goal. ${pct.toStringAsFixed(0)}% of the way there!';
  }

  String _getMovingAwayMessage(String goal, double bmi) {
    return 'BMI ${bmi.toStringAsFixed(1)} — Trending away from your ${_goalLabel(goal)} target. Consider adjusting your diet and training intensity.';
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'build_muscle': return 'muscle building';
      case 'lose_weight': return 'weight loss';
      case 'get_fit': return 'fitness';
      case 'strength': return 'strength';
      case 'endurance': return 'endurance';
      default: return 'active lifestyle';
    }
  }
}

// ── DATA MODELS ───────────────────────────────────────────

enum ProgressDirection { improving, onTrack, movingAway, neutral }

class BMIProgressResult {
  final ProgressDirection direction;
  final String message;
  final double percentage;
  final double currentBMI;
  final Map<String, double> targetRange;

  BMIProgressResult({
    required this.direction,
    required this.message,
    required this.percentage,
    required this.currentBMI,
    required this.targetRange,
  });
}

class SplitSuggestion {
  final String title;
  final String message;
  final List<String> exercises;
  final int weeklyGoal;

  SplitSuggestion({
    required this.title,
    required this.message,
    required this.exercises,
    required this.weeklyGoal,
  });
}