import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../theme/app_theme.dart';

/// Edit Quest Screen — allows users to modify an existing quest
/// Pre-fills the form with current quest data from SQLite
class EditQuestScreen extends StatefulWidget {
  final Map<String, dynamic> quest;

  const EditQuestScreen({super.key, required this.quest});

  @override
  State<EditQuestScreen> createState() =>
      _EditQuestScreenState();
}

class _EditQuestScreenState extends State<EditQuestScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();
  final QuestCrud _questCrud = QuestCrud();

  late TextEditingController _questNameController;
  late TextEditingController _descriptionController;

  late String selectedDuration;
  late int selectedWeeklyGoal;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill form with existing quest data
    _questNameController = TextEditingController(
        text: widget.quest['name'] ?? '');
    _descriptionController = TextEditingController(
        text: widget.quest['description'] ?? '');

    // Convert weeks back to duration string
    selectedDuration =
        _weeksToDuration(widget.quest['duration_weeks'] ?? 1);
    selectedWeeklyGoal = widget.quest['weekly_goal'] ?? 3;
  }

  @override
  void dispose() {
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Converts week number back to display string
  String _weeksToDuration(int weeks) {
    switch (weeks) {
      case 1:
        return '1 Week';
      case 2:
        return '2 Weeks';
      case 4:
        return '1 Month';
      default:
        return '1 Week';
    }
  }

  /// Converts duration string to weeks for storage
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

  /// Saves updated quest data to SQLite
  Future<void> _saveQuest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _questCrud.updateQuest(
          widget.quest['id'],
          {
            'name': _questNameController.text.trim(),
            'description':
                _descriptionController.text.trim(),
            'duration_weeks':
                _durationToWeeks(selectedDuration),
            'weekly_goal': selectedWeeklyGoal,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quest updated! 💪'),
              backgroundColor: AppTheme.orange,
            ),
          );
          // Return true to tell home screen to reload
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update quest: $e'),
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
        title: const Text('EDIT QUEST'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                      'EDIT QUEST',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Update Your Challenge',
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

              // ── QUEST NAME ────────────────────────
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

              // ── DESCRIPTION ───────────────────────
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

              // ── DURATION ──────────────────────────
              _FieldLabel(
                  label: 'DURATION',
                  color: secondaryText),
              const SizedBox(height: 8),
              Row(
                children:
                    ['1 Week', '2 Weeks', '1 Month']
                        .map((duration) {
                  final isSelected =
                      selectedDuration == duration;
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() =>
                            selectedDuration = duration),
                        child: Container(
                          padding: const EdgeInsets
                              .symmetric(vertical: 14),
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

              // ── WEEKLY GOAL ───────────────────────
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
                            () => selectedWeeklyGoal = goal),
                        child: Container(
                          padding: const EdgeInsets
                              .symmetric(vertical: 14),
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

              // ── SAVE BUTTON ───────────────────────
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
                      : const Text('SAVE CHANGES'),
                ),
              ),

              const SizedBox(height: 12),

              // ── CANCEL BUTTON ─────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _FieldLabel(
      {required this.label, required this.color});

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