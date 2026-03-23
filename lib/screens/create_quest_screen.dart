import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _questNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Database instance
  final QuestCrud _questCrud = QuestCrud();

  String selectedDuration = '1 Week';
  int selectedWeeklyGoal = 3;
  bool _isSaving = false; // Prevents double tapping save button

  @override
  void dispose() {
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Converts duration string to number of weeks for database
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

  // Saves the quest to SQLite
  Future<void> _saveQuest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final questId = await _questCrud.insertQuest({
          'name': _questNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'duration_weeks': _durationToWeeks(selectedDuration),
          'weekly_goal': selectedWeeklyGoal,
          'start_date': DateTime.now().toIso8601String(),
          'is_active': 1,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quest saved! ID: $questId'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the form after saving
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
      appBar: AppBar(
        title: const Text('Create Quest'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // Quest Name input (required)
                  TextFormField(
                    controller: _questNameController,
                    decoration: const InputDecoration(
                      labelText: 'Quest Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a quest name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Optional description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Duration dropdown
                  DropdownButtonFormField<String>(
                    value: selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1 Week', child: Text('1 Week')),
                      DropdownMenuItem(value: '2 Weeks', child: Text('2 Weeks')),
                      DropdownMenuItem(value: '1 Month', child: Text('1 Month')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedDuration = value!);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Weekly goal dropdown
                  DropdownButtonFormField<int>(
                    value: selectedWeeklyGoal,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Goal',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 workout')),
                      DropdownMenuItem(value: 2, child: Text('2 workouts')),
                      DropdownMenuItem(value: 3, child: Text('3 workouts')),
                      DropdownMenuItem(value: 4, child: Text('4 workouts')),
                      DropdownMenuItem(value: 5, child: Text('5 workouts')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedWeeklyGoal = value!);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Save button — shows loading spinner while saving
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveQuest,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Quest',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}