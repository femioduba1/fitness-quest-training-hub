import 'package:flutter/material.dart';
import '../data/sample_exercises.dart';

// This screen shows the exercise library.
// Users can search exercises by name and also filter them by difficulty.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  // Stores what the user types into the search bar
  String searchText = '';

  // Stores the currently selected difficulty filter
  String selectedDifficulty = 'All';

  @override
  Widget build(BuildContext context) {
    // This creates a filtered version of the exercise list
    // based on both the search input and the selected difficulty
    final filteredExercises = sampleExercises.where((exercise) {
      final matchesSearch =
          exercise.name.toLowerCase().contains(searchText.toLowerCase());

      final matchesDifficulty =
          selectedDifficulty == 'All' || exercise.difficulty == selectedDifficulty;

      return matchesSearch && matchesDifficulty;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Search bar updates the screen in real time as the user types
            TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Dropdown lets the user filter exercises by difficulty level
            DropdownButtonFormField<String>(
              value: selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Expanded allows the list to take up the rest of the available screen space
            Expanded(
              child: filteredExercises.isEmpty
                  // This message shows if no exercises match the user's filters
                  ? const Center(
                      child: Text(
                        'No exercises found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  // ListView.builder displays the filtered exercise list dynamically
                  : ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.fitness_center),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.muscleGroup} • ${exercise.difficulty} • ${exercise.equipment}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}