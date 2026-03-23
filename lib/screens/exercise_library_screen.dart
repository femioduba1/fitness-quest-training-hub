import 'package:flutter/material.dart';
import '../database/crud/exercise_crud.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final ExerciseCrud _exerciseCrud = ExerciseCrud();

  String searchText = '';
  String selectedDifficulty = 'All';

  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises(); // Load exercises from SQLite when screen opens
  }

  // Loads exercises from SQLite applying search and filter
  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> results;

      // If user typed something, use search
      if (searchText.isNotEmpty) {
        results = await _exerciseCrud.searchExercises(searchText);

        // Apply difficulty filter on top of search results
        if (selectedDifficulty != 'All') {
          results = results
              .where((e) => e['difficulty'] == selectedDifficulty)
              .toList();
        }
      } else {
        // Otherwise use filter
        results = await _exerciseCrud.filterExercises(
          difficulty: selectedDifficulty == 'All' ? null : selectedDifficulty,
        );
      }

      setState(() {
        _exercises = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load exercises: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [

            // Search bar — reloads from SQLite on every keystroke
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
                setState(() => searchText = value);
                _loadExercises();
              },
            ),
            const SizedBox(height: 12),

            // Difficulty filter dropdown
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
                DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                setState(() => selectedDifficulty = value!);
                _loadExercises();
              },
            ),
            const SizedBox(height: 16),

            // Exercise list
            Expanded(
              child: _isLoading
                  // Show spinner while loading from SQLite
                  ? const Center(child: CircularProgressIndicator())
                  : _exercises.isEmpty
                      // Empty state
                      ? const Center(
                          child: Text(
                            'No exercises found.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      // Exercise cards
                      : ListView.builder(
                          itemCount: _exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _exercises[index];

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
                                title: Text(exercise['name']),
                                subtitle: Text(
                                  '${exercise['muscle_group']} • ${exercise['difficulty']} • ${exercise['equipment'] ?? 'No equipment'}',
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