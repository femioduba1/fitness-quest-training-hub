import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../database/crud/exercise_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';

/// Create Quest Screen — allows users to create a custom quest
/// or choose from pre-built workout split templates
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
  final ExerciseCrud _exerciseCrud = ExerciseCrud();

  String selectedDuration = '1 Month';
  int selectedWeeklyGoal = 5;
  bool _isSaving = false;
  String? _selectedTemplate;

  // All exercises from database
  List<Map<String, dynamic>> _allExercises = [];

  // Selected exercises with sets/reps
  List<Map<String, dynamic>> _selectedExercises = [];

  // ── WORKOUT SPLIT TEMPLATES ───────────────────────────
  static const List<Map<String, dynamic>> _templates = [
    {
      'id': 'custom',
      'name': 'Custom Split',
      'description': 'Build your own workout from scratch',
      'icon': '✏️',
      'color': 0xFF9E9E9E,
      'weeklyGoal': 3,
      'duration': '1 Month',
      'exercises': <String>[],
    },
    {
      'id': 'bro_split',
      'name': 'Bro Split',
      'description':
          'One muscle group per day — 5 exercises each. Chest · Back · Legs · Shoulders · Arms',
      'icon': '💪',
      'color': 0xFFFF6000,
      'weeklyGoal': 5,
      'duration': '1 Month',
      'exercises': [
        // Chest Day
        'Bench Press',
        'Push-Up',
        // Back Day
        'Pull-Up',
        'Deadlift',
        // Legs Day
        'Squat',
        'Lunges',
        // Arms Day
        'Bicep Curl',
        // Core Day
        'Plank',
      ],
    },
    {
      'id': 'ppl',
      'name': 'Push Pull Legs',
      'description':
          'Push (Chest/Shoulders/Triceps) · Pull (Back/Biceps) · Legs. 6 days per week.',
      'icon': '🔥',
      'color': 0xFF2196F3,
      'weeklyGoal': 6,
      'duration': '1 Month',
      'exercises': [
        // Push
        'Bench Press',
        'Push-Up',
        // Pull
        'Pull-Up',
        'Bicep Curl',
        'Deadlift',
        // Legs
        'Squat',
        'Lunges',
        'Plank',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _questNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final exercises = await _exerciseCrud.getAllExercises();
    if (mounted) setState(() => _allExercises = exercises);
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
      selectedDuration = '1 Month';
      selectedWeeklyGoal = 5;
      _selectedExercises = [];
      _selectedTemplate = null;
    });
  }

  /// Applies a template to the form — auto-fills all fields
  void _applyTemplate(Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = template['id'];

      if (template['id'] == 'custom') {
        // Reset to blank for custom
        _questNameController.clear();
        _descriptionController.clear();
        selectedDuration = '1 Week';
        selectedWeeklyGoal = 3;
        _selectedExercises = [];
        return;
      }

      // Auto-fill quest details
      _questNameController.text = template['name'];
      _descriptionController.text = template['description'];
      selectedDuration = template['duration'];
      selectedWeeklyGoal = template['weeklyGoal'];

      // Match exercise names to database exercises
      final exerciseNames =
          List<String>.from(template['exercises']);
      _selectedExercises = [];

      for (final name in exerciseNames) {
        final match = _allExercises.firstWhere(
          (e) => e['name'] == name,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          _selectedExercises.add({
            'exercise': match,
            'sets': 3,
            'reps': 10,
          });
        }
      }
    });
  }

  /// Opens exercise picker bottom sheet
  Future<void> _openExercisePicker() async {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final primaryText = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryText = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;

    String searchText = '';
    String filterDifficulty = 'All';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _allExercises.where((e) {
              final matchesSearch = e['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
              final matchesDifficulty =
                  filterDifficulty == 'All' ||
                      e['difficulty'] == filterDifficulty;
              return matchesSearch && matchesDifficulty;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius:
                              BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SELECT EXERCISES',
                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: secondaryText),
                            onPressed: () =>
                                Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: TextField(
                        style:
                            TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          hintText: 'Search exercises...',
                          hintStyle: TextStyle(
                              color: secondaryText),
                          prefixIcon: Icon(Icons.search,
                              color: secondaryText),
                        ),
                        onChanged: (value) =>
                            setSheetState(
                                () => searchText = value),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Difficulty chips
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            'Beginner',
                            'Intermediate',
                            'Advanced'
                          ].map((d) {
                            final isSelected =
                                filterDifficulty == d;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                      right: 8),
                              child: GestureDetector(
                                onTap: () => setSheetState(
                                    () =>
                                        filterDifficulty =
                                            d),
                                child: Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 14,
                                      vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.orange
                                        : isDark
                                            ? AppTheme
                                                .darkCardLight
                                            : AppTheme
                                                .lightCardLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),
                                  child: Text(
                                    d.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : secondaryText,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(color: borderColor, height: 1),

                    // Exercise list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final exercise = filtered[index];
                          final isSelected =
                              _selectedExercises.any((e) =>
                                  e['exercise']['id'] ==
                                  exercise['id']);

                          return GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                setState(() {
                                  _selectedExercises
                                      .removeWhere((e) =>
                                          e['exercise']
                                              ['id'] ==
                                          exercise['id']);
                                });
                              } else {
                                setState(() {
                                  _selectedExercises.add({
                                    'exercise': exercise,
                                    'sets': 3,
                                    'reps': 10,
                                  });
                                });
                              }
                              setSheetState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8),
                              padding:
                                  const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.orange
                                        .withOpacity(0.1)
                                    : isDark
                                        ? AppTheme
                                            .darkCardLight
                                        : AppTheme
                                            .lightCardLight,
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.orange
                                      : borderColor,
                                  width:
                                      isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.orange
                                          : AppTheme.orange
                                              .withOpacity(
                                                  0.15),
                                      borderRadius:
                                          BorderRadius
                                              .circular(10),
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? Icons
                                              .check_rounded
                                          : Icons
                                              .fitness_center,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.orange,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${exercise['muscle_group']} • ${exercise['difficulty']}',
                                          style: TextStyle(
                                            color:
                                                secondaryText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color: AppTheme.orange,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Done button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: Text(
                            _selectedExercises.isEmpty
                                ? 'SKIP'
                                : 'DONE — ${_selectedExercises.length} SELECTED',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveQuest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _questCrud.insertQuest({
          'name': _questNameController.text.trim(),
          'description':
              _descriptionController.text.trim(),
          'duration_weeks':
              _durationToWeeks(selectedDuration),
          'weekly_goal': selectedWeeklyGoal,
          'start_date': DateTime.now().toIso8601String(),
          'is_active': 1,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedExercises.isEmpty
                    ? 'Quest created! 💪'
                    : 'Quest created with ${_selectedExercises.length} exercises! 💪',
              ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                    borderRadius:
                        BorderRadius.circular(16),
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

                // ── TEMPLATE SELECTOR ──────────────────
                _FieldLabel(
                    label: 'CHOOSE A TEMPLATE',
                    color: secondaryText),
                const SizedBox(height: 10),

                // Template cards
                ..._templates.map((template) {
                  final isSelected =
                      _selectedTemplate == template['id'];
                  final color =
                      Color(template['color'] as int);

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () =>
                          _applyTemplate(template),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.1)
                              : cardColor,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Emoji icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color
                                    .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                              child: Center(
                                child: Text(
                                  template['icon'],
                                  style: const TextStyle(
                                      fontSize: 26),
                                ),
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
                                    template['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? color
                                          : primaryText,
                                      fontWeight:
                                          FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template['description'],
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (template['id'] !=
                                      'custom') ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                          decoration:
                                              BoxDecoration(
                                            color: color
                                                .withOpacity(
                                                    0.15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: Text(
                                            '${template['weeklyGoal']}x/week',
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                          decoration:
                                              BoxDecoration(
                                            color: color
                                                .withOpacity(
                                                    0.15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        6),
                                          ),
                                          child: Text(
                                            template[
                                                'duration'],
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Selected indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: color,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // ── QUEST NAME ─────────────────────────
                _FieldLabel(
                    label: 'QUEST NAME',
                    color: secondaryText),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questNameController,
                  style: TextStyle(color: primaryText),
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. 30-Day Strength Builder',
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
                  children: [
                    '1 Week',
                    '2 Weeks',
                    '1 Month'
                  ].map((duration) {
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

                // ── WEEKLY GOAL ────────────────────────
                _FieldLabel(
                    label: 'WEEKLY GOAL',
                    color: secondaryText),
                const SizedBox(height: 8),
                Row(
                  children:
                      [1, 2, 3, 4, 5, 6].map((goal) {
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
                        color: secondaryText,
                        fontSize: 12),
                  ),
                ),

                const SizedBox(height: 24),

                // ── EXERCISES ──────────────────────────
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    _FieldLabel(
                        label: 'EXERCISES',
                        color: secondaryText),
                    GestureDetector(
                      onTap: _openExercisePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.orange
                              .withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add,
                                color: AppTheme.orange,
                                size: 16),
                            SizedBox(width: 4),
                            Text(
                              'ADD',
                              style: TextStyle(
                                color: AppTheme.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Exercise list or empty state
                _selectedExercises.isEmpty
                    ? GestureDetector(
                        onTap: _openExercisePicker,
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                                color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.fitness_center,
                                  color: secondaryText,
                                  size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'No exercises added yet',
                                style: TextStyle(
                                    color: primaryText,
                                    fontWeight:
                                        FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to browse the exercise library',
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _selectedExercises
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final exercise = item['exercise']
                              as Map<String, dynamic>;

                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 10),
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                  color: borderColor),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration:
                                          BoxDecoration(
                                        color: AppTheme
                                            .orange
                                            .withOpacity(
                                                0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    10),
                                      ),
                                      child: const Icon(
                                        Icons.fitness_center,
                                        color:
                                            AppTheme.orange,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${exercise['muscle_group']} • ${exercise['difficulty']}',
                                            style: TextStyle(
                                              color:
                                                  secondaryText,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons
                                            .remove_circle_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedExercises
                                              .removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Sets and Reps
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            'SETS',
                                            style: TextStyle(
                                              color:
                                                  secondaryText,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              letterSpacing:
                                                  1,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 6),
                                          Row(
                                            children: [
                                              _CounterButton(
                                                icon: Icons
                                                    .remove,
                                                onTap: () {
                                                  if (item['sets'] >
                                                      1) {
                                                    setState(
                                                        () {
                                                      _selectedExercises[index]
                                                              [
                                                              'sets'] =
                                                          item['sets'] -
                                                              1;
                                                    });
                                                  }
                                                },
                                              ),
                                              const SizedBox(
                                                  width: 12),
                                              Text(
                                                '${item['sets']}',
                                                style:
                                                    TextStyle(
                                                  color:
                                                      primaryText,
                                                  fontWeight:
                                                      FontWeight
                                                          .w900,
                                                  fontSize:
                                                      18,
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: 12),
                                              _CounterButton(
                                                icon: Icons.add,
                                                onTap: () {
                                                  setState(
                                                      () {
                                                    _selectedExercises[index]
                                                            [
                                                            'sets'] =
                                                        item['sets'] +
                                                            1;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: borderColor,
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                                left: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'REPS',
                                              style:
                                                  TextStyle(
                                                color:
                                                    secondaryText,
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                                letterSpacing:
                                                    1,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 6),
                                            Row(
                                              children: [
                                                _CounterButton(
                                                  icon: Icons
                                                      .remove,
                                                  onTap: () {
                                                    if (item['reps'] >
                                                        1) {
                                                      setState(
                                                          () {
                                                        _selectedExercises[index]['reps'] =
                                                            item['reps'] -
                                                                1;
                                                      });
                                                    }
                                                  },
                                                ),
                                                const SizedBox(
                                                    width: 12),
                                                Text(
                                                  '${item['reps']}',
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        primaryText,
                                                    fontWeight:
                                                        FontWeight
                                                            .w900,
                                                    fontSize:
                                                        18,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: 12),
                                                _CounterButton(
                                                  icon:
                                                      Icons.add,
                                                  onTap: () {
                                                    setState(
                                                        () {
                                                      _selectedExercises[index]['reps'] =
                                                          item['reps'] +
                                                              1;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 32),

                // ── CREATE BUTTON ──────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSaving ? null : _saveQuest,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
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

/// Counter +/- button widget for sets and reps
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkCardLight
              : AppTheme.lightCardLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, size: 16, color: AppTheme.orange),
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