import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../theme/app_theme.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _questNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
      case '1 Week': return 1;
      case '2 Weeks': return 2;
      case '1 Month': return 4;
      default: return 1;
    }
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
          _questNameController.clear();
          _descriptionController.clear();
          setState(() {
            selectedDuration = '1 Week';
            selectedWeeklyGoal = 3;
          });
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
    return Scaffold(
      appBar: AppBar(title: const Text('CREATE QUEST')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.orange, AppTheme.orangeDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

              // Section label
              const _FieldLabel(label: 'QUEST NAME'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questNameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. 30-Day Strength Builder',
                  prefixIcon:
                      Icon(Icons.flag, color: AppTheme.orange),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a quest name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const _FieldLabel(label: 'DESCRIPTION (OPTIONAL)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'What is this quest about?',
                  prefixIcon:
                      Icon(Icons.notes, color: AppTheme.orange),
                ),
              ),

              const SizedBox(height: 20),

              const _FieldLabel(label: 'DURATION'),
              const SizedBox(height: 8),

              // Duration selector buttons
              Row(
                children: ['1 Week', '2 Weeks', '1 Month'].map((duration) {
                  final isSelected = selectedDuration == duration;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedDuration = duration),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.orange
                                : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.orange
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            duration.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
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

              const _FieldLabel(label: 'WEEKLY GOAL'),
              const SizedBox(height: 8),

              // Weekly goal selector
              Row(
                children: [1, 2, 3, 4, 5].map((goal) {
                  final isSelected = selectedWeeklyGoal == goal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedWeeklyGoal = goal),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.orange
                                : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.orange
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            '$goal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
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
              const Center(
                child: Text(
                  'workouts per week',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuest,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('CREATE QUEST'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}