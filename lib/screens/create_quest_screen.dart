import 'package:flutter/material.dart';

// This screen is where users create a new workout quest.
// It includes a form with inputs like name, description, duration, and weekly goal.
class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {

  // This key is used to manage and validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers used to grab input values from the text fields
  final TextEditingController _questNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // These store the selected dropdown values
  String selectedDuration = '1 Week';
  int selectedWeeklyGoal = 3;

  @override
  void dispose() {
    // Clean up controllers when the screen is removed
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // This function runs when the user presses "Save Quest"
  // It validates the form and (later) will connect to SQLite
  void _saveQuest() {
    if (_formKey.currentState!.validate()) {
      // For now, just show a message confirming validation worked
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quest'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Keeps layout clean and prevents overflow when keyboard opens
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),

            // Form widget wraps all input fields so we can validate everything together
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // Quest Name input (required field)
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

                  // Optional description input
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dropdown for selecting how long the quest lasts
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

                  // Dropdown for selecting how many workouts per week
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

                  // Save button triggers validation and (later) database save
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveQuest,
                      child: const Text(
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