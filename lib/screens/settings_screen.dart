import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService.instance;
  final TextEditingController _nameController = TextEditingController();

  String _themeMode = 'system';
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

  // Load all saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _prefs.getUserName(),
      _prefs.getThemeMode(),
      _prefs.getWeightUnit(),
      _prefs.getNotificationsEnabled(),
    ]);

    setState(() {
      _nameController.text = results[0] as String;
      _themeMode = results[1] as String;
      _weightUnit = results[2] as String;
      _notificationsEnabled = results[3] as bool;
      _isLoading = false;
    });
  }

  // Save all settings and update theme immediately
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      await Future.wait([
        _prefs.setUserName(_nameController.text.trim()),
        _prefs.setThemeMode(_themeMode),
        _prefs.setWeightUnit(_weightUnit),
        _prefs.setNotificationsEnabled(_notificationsEnabled),
      ]);

      // Tell the app to update the theme immediately
      FitnessQuestApp.appKey.currentState?.updateTheme(_themeMode);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Clears all saved preferences and resets the form
  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _prefs.clearAll();
      await _loadSettings();

      // Reset theme back to system
      FitnessQuestApp.appKey.currentState?.updateTheme('system');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── PROFILE SECTION ──────────────────────────
                  const _SectionHeader(title: 'Profile'),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── APPEARANCE SECTION ───────────────────────
                  const _SectionHeader(title: 'Appearance'),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _themeMode,
                        decoration: const InputDecoration(
                          labelText: 'Theme',
                          prefixIcon: Icon(Icons.palette),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'system',
                            child: Text('System Default'),
                          ),
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: 'dark',
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _themeMode = value!);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── PREFERENCES SECTION ──────────────────────
                  const _SectionHeader(title: 'Preferences'),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [

                          // Weight unit dropdown
                          DropdownButtonFormField<String>(
                            value: _weightUnit,
                            decoration: const InputDecoration(
                              labelText: 'Weight Unit',
                              prefixIcon: Icon(Icons.fitness_center),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'lbs',
                                child: Text('Pounds (lbs)'),
                              ),
                              DropdownMenuItem(
                                value: 'kg',
                                child: Text('Kilograms (kg)'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _weightUnit = value!);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Notifications toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notifications'),
                            subtitle: const Text('Enable workout reminders'),
                            secondary: const Icon(Icons.notifications),
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── SAVE BUTTON ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveSettings,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Settings',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── RESET BUTTON ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _resetSettings,
                      child: const Text(
                        'Reset to Default',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// Reusable section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}