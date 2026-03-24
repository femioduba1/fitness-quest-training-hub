import 'package:flutter/material.dart';
import '../database/crud/exercise_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'log_workout_sheet.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends State<ExerciseLibraryScreen> {
  final ExerciseCrud _exerciseCrud = ExerciseCrud();

  String searchText = '';
  String selectedDifficulty = 'All';
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return const Color(0xFF4CAF50);
      case 'Intermediate':
        return const Color(0xFFFFC107);
      case 'Advanced':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _muscleIcon(String muscle) {
    switch (muscle) {
      case 'Chest':
        return Icons.sports_gymnastics;
      case 'Back':
        return Icons.accessibility_new;
      case 'Legs':
        return Icons.directions_run;
      case 'Core':
        return Icons.circle_outlined;
      case 'Arms':
        return Icons.fitness_center;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    if (!mounted) return;
    try {
      List<Map<String, dynamic>> results;
      if (searchText.isNotEmpty) {
        results =
            await _exerciseCrud.searchExercises(searchText);
        if (selectedDifficulty != 'All') {
          results = results
              .where((e) =>
                  e['difficulty'] == selectedDifficulty)
              .toList();
        }
      } else {
        results = await _exerciseCrud.filterExercises(
          difficulty: selectedDifficulty == 'All'
              ? null
              : selectedDifficulty,
        );
      }
      if (!mounted) return;
      setState(() {
        _exercises = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _openLogSheet(Map<String, dynamic> exercise) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : AppTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          LogWorkoutSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;
    final secondaryText = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final primaryText = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXERCISE LIBRARY'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              menuKey.currentState?.toggleMenu(),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        backgroundColor: cardColor,
        displacement: 80,
        strokeWidth: 3,
        onRefresh: _loadExercises,
        child: Column(
          children: [

            // ── SEARCH & FILTER ──────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: primaryText),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle:
                          TextStyle(color: secondaryText),
                      prefixIcon: Icon(Icons.search,
                          color: secondaryText),
                      suffixIcon: searchText.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: secondaryText),
                              onPressed: () {
                                setState(
                                    () => searchText = '');
                                _loadExercises();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => searchText = value);
                      _loadExercises();
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Beginner',
                        'Intermediate',
                        'Advanced'
                      ].map((difficulty) {
                        final isSelected =
                            selectedDifficulty == difficulty;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() =>
                                  selectedDifficulty =
                                      difficulty);
                              _loadExercises();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.orange
                                    : cardColor,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.orange
                                      : borderColor,
                                ),
                              ),
                              child: Text(
                                difficulty.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tap an exercise to log a workout',
                      style: TextStyle(
                          color: secondaryText, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── EXERCISE LIST ────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.orange))
                  : _exercises.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  'No exercises found.',
                                  style: TextStyle(
                                      color: secondaryText),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 16),
                          itemCount: _exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                                _exercises[index];
                            final diffColor =
                                _difficultyColor(
                                    exercise['difficulty']);
                            return GestureDetector(
                              onTap: () =>
                                  _openLogSheet(exercise),
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: 10),
                                padding:
                                    const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius:
                                      BorderRadius.circular(
                                          16),
                                  border: Border.all(
                                      color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppTheme.orange
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(12),
                                      ),
                                      child: Icon(
                                        _muscleIcon(exercise[
                                            'muscle_group']),
                                        color: AppTheme.orange,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            exercise['name'],
                                            style: TextStyle(
                                              color: primaryText,
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          Text(
                                            '${exercise['muscle_group']} • ${exercise['equipment'] ?? 'No equipment'}',
                                            style: TextStyle(
                                              color: secondaryText,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                          decoration:
                                              BoxDecoration(
                                            color: diffColor
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                          ),
                                          child: Text(
                                            exercise['difficulty']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: diffColor,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Icon(
                                          Icons.add_circle,
                                          color: AppTheme.orange,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ],
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