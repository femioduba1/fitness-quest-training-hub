import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() =>
      _CreateQuestScreenState();
}

class _CreateQuestScreenState
    extends State<CreateQuestScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();
  final TextEditingController _questNameController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final QuestCrud _questCrud = QuestCrud();

  String selectedDuration = '1 Week';
  int selectedWeeklyGoal = 3;
  bool _isSaving = false;

  @override
  void dispose() {
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int _durationToWeeks(String duration) {
    switch (duration) {
      case '1 Week':
        return 1;
      case '2 Weeks':
        return 2;
      case '1 Month':
        return 4;
      default:
        return 1;
    }
  }

  Future<void> _resetForm() async {
    setState(() {
      _questNameController.clear();
      _descriptionController.clear();
      selectedDuration = '1 Week';
      selectedWeeklyGoal = 3;
    });
  }

  Future<void> _saveQuest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _questCrud.insertQuest({
          'name': _questNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'duration_weeks': _durationToWeeks(selectedDuration),
          'weekly_goal': selectedWeeklyGoal,
          'start_date': DateTime.now().toIso8601String(),
          'is_active': 1,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quest created! Time to grind 💪'),
              backgroundColor: AppTheme.orange,
            ),
          );
          await _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save quest: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
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
        title: const Text('CREATE QUEST'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              menuKey.currentState?.toggleMenu(),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        backgroundColor: cardColor,
        displacement: 60,
        onRefresh: _resetForm,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── HEADER BANNER ──────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.orange,
                        AppTheme.orangeDark
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW QUEST',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Define Your Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── QUEST NAME ─────────────────────────
                _FieldLabel(
                    label: 'QUEST NAME',
                    color: secondaryText),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questNameController,
                  style: TextStyle(color: primaryText),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 30-Day Strength Builder',
                    prefixIcon: Icon(Icons.flag,
                        color: AppTheme.orange),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a quest name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── DESCRIPTION ────────────────────────
                _FieldLabel(
                    label: 'DESCRIPTION (OPTIONAL)',
                    color: secondaryText),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: primaryText),
                  decoration: const InputDecoration(
                    hintText: 'What is this quest about?',
                    prefixIcon: Icon(Icons.notes,
                        color: AppTheme.orange),
                  ),
                ),

                const SizedBox(height: 20),

                // ── DURATION ───────────────────────────
                _FieldLabel(
                    label: 'DURATION',
                    color: secondaryText),
                const SizedBox(height: 8),
                Row(
                  children: ['1 Week', '2 Weeks', '1 Month']
                      .map((duration) {
                    final isSelected =
                        selectedDuration == duration;
                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => selectedDuration =
                                  duration),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.orange
                                  : cardColor,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.orange
                                    : borderColor,
                              ),
                            ),
                            child: Text(
                              duration.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : secondaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ── WEEKLY GOAL ────────────────────────
                _FieldLabel(
                    label: 'WEEKLY GOAL',
                    color: secondaryText),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 3, 4, 5].map((goal) {
                    final isSelected =
                        selectedWeeklyGoal == goal;
                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => selectedWeeklyGoal =
                                  goal),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.orange
                                  : cardColor,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.orange
                                    : borderColor,
                              ),
                            ),
                            child: Text(
                              '$goal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : secondaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'workouts per week',
                    style: TextStyle(
                        color: secondaryText, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 32),

                // ── SAVE BUTTON ────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveQuest,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : const Text('CREATE QUEST'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _FieldLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}