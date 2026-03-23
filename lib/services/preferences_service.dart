import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._internal();
  PreferencesService._internal();

  // Keys
  static const String _keyUserName = 'user_name';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyWeightUnit = 'weight_unit';
  static const String _keyHasOnboarded = 'has_onboarded';

  // ─── USERNAME ───────────────────────────────────────────
  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Athlete';
  }

  // ─── THEME ──────────────────────────────────────────────
  // 'system', 'light', 'dark'
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  // ─── NOTIFICATIONS ──────────────────────────────────────
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // ─── WEIGHT UNIT ────────────────────────────────────────
  // 'kg' or 'lbs'
  Future<void> setWeightUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeightUnit, unit);
  }

  Future<String> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWeightUnit) ?? 'lbs';
  }

  // ─── ONBOARDING ─────────────────────────────────────────
  Future<void> setHasOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOnboarded, value);
  }

  Future<bool> getHasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOnboarded) ?? false;
  }

  // ─── CLEAR ALL ──────────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}