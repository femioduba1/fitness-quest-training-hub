import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../widgets/theme_toggle.dart';

/// Settings Screen — theme toggle, username, weight unit
/// and notifications. Also contains reset onboarding for testing.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs =
      PreferencesService.instance;
  final TextEditingController _nameController =
      TextEditingController();

  String _themeMode = 'dark';
  String _weightUnit = 'lbs';
  bool _notificationsEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Loads all saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    if (!mounted) return;
    try {
      final results = await Future.wait([
        _prefs.getUserName(),
        _prefs.getThemeMode(),
        _prefs.getWeightUnit(),
        _prefs.getNotificationsEnabled(),
      ]);
      if (!mounted) return;
      setState(() {
        _nameController.text = results[0] as String;
        _themeMode = results[1] as String;
        _weightUnit = results[2] as String;
        _notificationsEnabled = results[3] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// Called after theme toggle animation completes
  Future<void> _onThemeToggled(bool isDark) async {
    final mode = isDark ? 'dark' : 'light';
    setState(() => _themeMode = mode);
    await _prefs.setThemeMode(mode);
    FitnessQuestApp.appKey.currentState?.updateTheme(mode);
  }

  /// Saves all settings to SharedPreferences
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await Future.wait([
        _prefs.setUserName(_nameController.text.trim()),
        _prefs.setThemeMode(_themeMode),
        _prefs.setWeightUnit(_weightUnit),
        _prefs.setNotificationsEnabled(
            _notificationsEnabled),
      ]);
      FitnessQuestApp.appKey.currentState
          ?.updateTheme(_themeMode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved!'),
            backgroundColor: AppTheme.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Clears all preferences and resets to defaults
  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content:
            const Text('Reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _prefs.clearAll();
      await _loadSettings();
      FitnessQuestApp.appKey.currentState
          ?.updateTheme('dark');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to default'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Resets onboarding flag so it shows again on next launch
  Future<void> _resetOnboarding() async {
    await _prefs.setHasOnboarded(false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Onboarding reset — restart app to see it'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;
    final primaryText = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryText = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              menuKey.currentState?.toggleMenu(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.orange))
          : RefreshIndicator(
              color: AppTheme.orange,
              backgroundColor: cardColor,
              displacement: 80,
              strokeWidth: 3,
              onRefresh: _loadSettings,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ── PROFILE ──────────────────────
                    _SectionLabel(
                        label: 'PROFILE',
                        color: secondaryText),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(16),
                        border:
                            Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style:
                            TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          labelStyle: TextStyle(
                              color: secondaryText),
                          prefixIcon: const Icon(
                              Icons.person,
                              color: AppTheme.orange),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── APPEARANCE ────────────────────
                    _SectionLabel(
                        label: 'APPEARANCE',
                        color: secondaryText),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(16),
                        border:
                            Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Theme',
                                  style: TextStyle(
                                      color: primaryText,
                                      fontWeight:
                                          FontWeight.w700,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                _themeMode == 'dark'
                                    ? 'Dark mode'
                                    : 'Light mode',
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          ThemeToggle(
                            isDark: _themeMode == 'dark',
                            onToggled: _onThemeToggled,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── PREFERENCES ───────────────────
                    _SectionLabel(
                        label: 'PREFERENCES',
                        color: secondaryText),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(16),
                        border:
                            Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [

                          // Weight unit
                          Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.fitness_center,
                                        color: AppTheme.orange,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Text('Weight Unit',
                                        style: TextStyle(
                                            color:
                                                primaryText)),
                                  ],
                                ),
                                Row(
                                  children: ['lbs', 'kg']
                                      .map((unit) {
                                    final isSelected =
                                        _weightUnit == unit;
                                    return Padding(
                                      padding:
                                          const EdgeInsets
                                              .only(left: 8),
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () =>
                                                _weightUnit =
                                                    unit),
                                        child: Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 14,
                                              vertical: 6),
                                          decoration:
                                              BoxDecoration(
                                            color: isSelected
                                                ? AppTheme
                                                    .orange
                                                : isDark
                                                    ? AppTheme
                                                        .darkCardLight
                                                    : AppTheme
                                                        .lightCardLight,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        8),
                                          ),
                                          child: Text(
                                            unit.toUpperCase(),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors
                                                      .white
                                                  : secondaryText,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          Divider(
                              height: 1,
                              color: borderColor),

                          // Notifications toggle
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.notifications,
                                        color: AppTheme.orange,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text('Notifications',
                                            style: TextStyle(
                                                color:
                                                    primaryText)),
                                        Text(
                                            'Workout reminders',
                                            style: TextStyle(
                                                color:
                                                    secondaryText,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value:
                                      _notificationsEnabled,
                                  onChanged: (value) =>
                                      setState(() =>
                                          _notificationsEnabled =
                                              value),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── SAVE BUTTON ───────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isSaving ? null : _saveSettings,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                              )
                            : const Text('SAVE SETTINGS'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── RESET SETTINGS BUTTON ─────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _resetSettings,
                        child:
                            const Text('RESET TO DEFAULT'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── RESET ONBOARDING BUTTON ───────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                            Icons.restart_alt_rounded,
                            size: 16),
                        label: const Text(
                            'RESET ONBOARDING'),
                        onPressed: _resetOnboarding,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(
                              color: Colors.blue),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2));
  }
}