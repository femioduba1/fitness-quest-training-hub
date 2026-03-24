import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistent user settings using SharedPreferences
class PreferencesService {
  static final PreferencesService instance =
      PreferencesService._internal();
  PreferencesService._internal();

  static const String _keyUserName = 'user_name';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled =
      'notifications_enabled';
  static const String _keyWeightUnit = 'weight_unit';
  static const String _keyHasOnboarded = 'has_onboarded';
  static const String _keyFitnessGoal = 'fitness_goal';
  static const String _keyExperienceLevel =
      'experience_level';
  static const String _keyWorkoutFrequency =
      'workout_frequency';
  static const String _keyHeightCm = 'height_cm';
  static const String _keyInitialWeightKg =
      'initial_weight_kg';

  // ── USERNAME ─────────────────────────────────────────
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Athlete';
  }

  // ── THEME ─────────────────────────────────────────────
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'dark';
  }

  // ── NOTIFICATIONS ─────────────────────────────────────
  Future<void> setNotificationsEnabled(
      bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // ── WEIGHT UNIT ───────────────────────────────────────
  Future<void> setWeightUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeightUnit, unit);
  }

  Future<String> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWeightUnit) ?? 'lbs';
  }

  // ── ONBOARDING ────────────────────────────────────────
  Future<void> setHasOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOnboarded, value);
  }

  Future<bool> getHasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOnboarded) ?? false;
  }

  // ── FITNESS GOAL ──────────────────────────────────────
  Future<void> setFitnessGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFitnessGoal, goal);
  }

  Future<String> getFitnessGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFitnessGoal) ?? '';
  }

  // ── EXPERIENCE LEVEL ──────────────────────────────────
  Future<void> setExperienceLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExperienceLevel, level);
  }

  Future<String> getExperienceLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyExperienceLevel) ?? '';
  }

  // ── WORKOUT FREQUENCY ─────────────────────────────────
  Future<void> setWorkoutFrequency(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWorkoutFrequency, days);
  }

  Future<int> getWorkoutFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWorkoutFrequency) ?? 3;
  }

  // ── HEIGHT ────────────────────────────────────────────
  Future<void> setHeightCm(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHeightCm, height);
  }

  Future<double> getHeightCm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyHeightCm) ?? 0.0;
  }

  // ── INITIAL WEIGHT ────────────────────────────────────
  Future<void> setInitialWeightKg(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyInitialWeightKg, weight);
  }

  Future<double> getInitialWeightKg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyInitialWeightKg) ?? 0.0;
  }

  /// Clears all saved preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}