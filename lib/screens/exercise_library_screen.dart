import 'package:flutter/material.dart';
import '../database/crud/exercise_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'log_workout_sheet.dart';

/// Exercise Library — browse, search and filter 60+ exercises
/// by muscle group and difficulty, tap any to log a workout
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
  String selectedMuscleGroup = 'All';
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  /// Difficulty levels for filter chips
  static const List<String> _difficulties = [
    'All', 'Beginner', 'Intermediate', 'Advanced'
  ];

  /// Muscle groups for filter chips
  static const List<String> _muscleGroups = [
    'All', 'Chest', 'Back', 'Legs',
    'Core', 'Arms', 'Shoulders'
  ];

  /// Color coding per difficulty level
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

  /// Icon per muscle group for visual clarity
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
      case 'Shoulders':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.fitness_center;
    }
  }

  /// Color per muscle group for icon tinting
  Color _muscleColor(String muscle) {
    switch (muscle) {
      case 'Chest':
        return const Color(0xFFFF6000);
      case 'Back':
        return const Color(0xFF2196F3);
      case 'Legs':
        return const Color(0xFF4CAF50);
      case 'Core':
        return const Color(0xFFFF9800);
      case 'Arms':
        return const Color(0xFF9C27B0);
      case 'Shoulders':
        return const Color(0xFFF44336);
      default:
        return AppTheme.orange;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  /// Loads exercises from SQLite applying all active filters
  Future<void> _loadExercises() async {
    if (!mounted) return;
    try {
      List<Map<String, dynamic>> results;

      if (searchText.isNotEmpty) {
        results =
            await _exerciseCrud.searchExercises(searchText);
        // Apply difficulty filter on search results
        if (selectedDifficulty != 'All') {
          results = results
              .where((e) =>
                  e['difficulty'] == selectedDifficulty)
              .toList();
        }
        // Apply muscle group filter on search results
        if (selectedMuscleGroup != 'All') {
          results = results
              .where((e) =>
                  e['muscle_group'] == selectedMuscleGroup)
              .toList();
        }
      } else {
        results = await _exerciseCrud.filterExercises(
          difficulty: selectedDifficulty == 'All'
              ? null
              : selectedDifficulty,
          muscleGroup: selectedMuscleGroup == 'All'
              ? null
              : selectedMuscleGroup,
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

  /// Builds a horizontal scrollable row of filter chips
  Widget _buildFilterChips({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
    required Color Function(String) activeColor,
    required Color borderColor,
    required Color secondaryText,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option;
          final color = isSelected && option != 'All'
              ? activeColor(option)
              : AppTheme.orange;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                onSelect(option);
                _loadExercises();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(
                          option == 'All' ? 1.0 : 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : borderColor,
                  ),
                ),
                child: Text(
                  option.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? option == 'All'
                            ? Colors.white
                            : color
                        : secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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

            // ── SEARCH & FILTERS ─────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // Search bar
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

                  // Muscle group filter label
                  Text(
                    'MUSCLE GROUP',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Muscle group chips
                  _buildFilterChips(
                    options: _muscleGroups,
                    selected: selectedMuscleGroup,
                    onSelect: (value) => setState(
                        () => selectedMuscleGroup = value),
                    activeColor: _muscleColor,
                    borderColor: borderColor,
                    secondaryText: secondaryText,
                  ),

                  const SizedBox(height: 12),

                  // Difficulty filter label
                  Text(
                    'DIFFICULTY',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Difficulty chips
                  _buildFilterChips(
                    options: _difficulties,
                    selected: selectedDifficulty,
                    onSelect: (value) => setState(
                        () => selectedDifficulty = value),
                    activeColor: (d) =>
                        _difficultyColor(d),
                    borderColor: borderColor,
                    secondaryText: secondaryText,
                  ),

                  const SizedBox(height: 12),

                  // Results count + hint
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_exercises.length} exercise${_exercises.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to log a workout',
                        style: TextStyle(
                            color: secondaryText,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── EXERCISE LIST ─────────────────────────
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
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                        Icons
                                            .fitness_center,
                                        color: secondaryText,
                                        size: 48),
                                    const SizedBox(
                                        height: 12),
                                    Text(
                                      'No exercises found',
                                      style: TextStyle(
                                          color:
                                              secondaryText,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w700),
                                    ),
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      'Try adjusting your filters',
                                      style: TextStyle(
                                          color:
                                              secondaryText,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                                  16, 0, 16, 16),
                          itemCount: _exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                                _exercises[index];
                            final diffColor =
                                _difficultyColor(
                                    exercise['difficulty']);
                            final muscleColor = _muscleColor(
                                exercise['muscle_group']);

                            return GestureDetector(
                              onTap: () =>
                                  _openLogSheet(exercise),
                              child: Container(
                                margin:
                                    const EdgeInsets.only(
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
                                    // Muscle group colored icon
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration:
                                          BoxDecoration(
                                        color: muscleColor
                                            .withOpacity(
                                                0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    12),
                                      ),
                                      child: Icon(
                                        _muscleIcon(exercise[
                                            'muscle_group']),
                                        color: muscleColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Exercise info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            exercise['name'],
                                            style: TextStyle(
                                              color:
                                                  primaryText,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          Row(
                                            children: [
                                              // Muscle group badge
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal:
                                                        6,
                                                    vertical:
                                                        2),
                                                decoration:
                                                    BoxDecoration(
                                                  color: muscleColor
                                                      .withOpacity(
                                                          0.15),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              4),
                                                ),
                                                child: Text(
                                                  exercise[
                                                      'muscle_group'],
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        muscleColor,
                                                    fontSize:
                                                        10,
                                                    fontWeight:
                                                        FontWeight
                                                            .w700,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: 6),
                                              Text(
                                                exercise[
                                                        'equipment'] ??
                                                    'No equipment',
                                                style:
                                                    TextStyle(
                                                  color:
                                                      secondaryText,
                                                  fontSize:
                                                      11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right side badges
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .end,
                                      children: [
                                        // Difficulty badge
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                          decoration:
                                              BoxDecoration(
                                            color: diffColor
                                                .withOpacity(
                                                    0.15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        8),
                                          ),
                                          child: Text(
                                            exercise[
                                                    'difficulty']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  diffColor,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 8),
                                        const Icon(
                                          Icons.add_circle,
                                          color:
                                              AppTheme.orange,
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