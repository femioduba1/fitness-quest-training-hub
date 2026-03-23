import 'package:flutter/material.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _questNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedDuration = '1 Week';
  int selectedWeeklyGoal = 3;

  @override
  void dispose() {
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveQuest() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quest validated. SQLite connection can be added next.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Workout Quest',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedDuration,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '1 Week',
                            child: Text('1 Week'),
                          ),
                          DropdownMenuItem(
                            value: '2 Weeks',
                            child: Text('2 Weeks'),
                          ),
                          DropdownMenuItem(
                            value: '1 Month',
                            child: Text('1 Month'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
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
                          setState(() {
                            selectedWeeklyGoal = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveQuest,
                          child: const Text('Save Quest'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}