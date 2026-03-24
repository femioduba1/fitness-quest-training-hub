import 'package:flutter/material.dart';
import '../database/crud/workout_log_crud.dart';
import '../database/crud/personal_record_crud.dart';
import '../database/crud/exercise_crud.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'charts_screen.dart';
import 'ai_trainer_screen.dart';
import 'progress_photos_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final PersonalRecordCrud _prCrud = PersonalRecordCrud();
  final ExerciseCrud _exerciseCrud = ExerciseCrud();
  final StreakService _streakService = StreakService.instance;

  int _currentStreak = 0;
  int _totalWorkouts = 0;
  int _weeklyWorkouts = 0;
  List<Map<String, dynamic>> _personalRecords = [];
  List<Map<String, dynamic>> _workoutHistory = [];
  List<bool> _weeklyActivity = List.filled(7, false);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;
    try {
      final results = await Future.wait([
        _streakService.getCurrentStreak(),
        _logCrud.getAllLogs(),
        _logCrud.getWeeklyWorkoutCount(),
        _exerciseCrud.getAllExercises(),
        _logCrud.getLogsWithExerciseNames(),
      ]);

      final allLogs =
          results[1] as List<Map<String, dynamic>>;
      final exercises =
          results[3] as List<Map<String, dynamic>>;
      final workoutHistory =
          results[4] as List<Map<String, dynamic>>;
      final weeklyActivity = await _buildWeeklyActivity();

      final List<Map<String, dynamic>> records = [];
      for (final exercise in exercises) {
        final best =
            await _prCrud.getBestRecord(exercise['id']);
        if (best != null) {
          records.add({
            'exercise_name': exercise['name'],
            'record_value': best['record_value'],
            'record_type': best['record_type'],
            'achieved_at': best['achieved_at'],
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _currentStreak = results[0] as int;
        _totalWorkouts = allLogs.length;
        _weeklyWorkouts = results[2] as int;
        _weeklyActivity = weeklyActivity;
        _personalRecords = records;
        _workoutHistory = workoutHistory;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<List<bool>> _buildWeeklyActivity() async {
    final now = DateTime.now();
    final List<bool> activity = List.filled(7, false);
    for (int i = 0; i < 7; i++) {
      final day =
          now.subtract(Duration(days: now.weekday - 1 - i));
      final dayStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final logs = await _logCrud.getTodaysLogs();
      final hasLog = logs
          .any((log) => log['logged_at'].startsWith(dayStr));
      activity[i] = hasLog;
    }
    return activity;
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
        title: const Text('PROGRESS'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              menuKey.currentState?.toggleMenu(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'AI Trainer',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AITrainerScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Charts & ML Analysis',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ChartsScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.orange))
          : RefreshIndicator(
              color: AppTheme.orange,
              backgroundColor: cardColor,
              displacement: 80,
              strokeWidth: 3,
              onRefresh: _loadProgress,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [

                  // ── ANALYTICS BANNER ─────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const ChartsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: const Row(
                        children: [
                          Icon(Icons.analytics,
                              color: Colors.white,
                              size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHARTS & ML ANALYSIS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Weekly • Monthly • Muscle Balance • Trends',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swipe_down,
                            color: secondaryText, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                              color: secondaryText,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── STATS ROW ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'STREAK',
                          value: '$_currentStreak',
                          unit: 'days',
                          icon: Icons.local_fire_department,
                          color: AppTheme.orange,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'TOTAL',
                          value: '$_totalWorkouts',
                          unit: 'workouts',
                          icon: Icons.check_circle,
                          color: const Color(0xFF4CAF50),
                          cardColor: cardColor,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'THIS WEEK',
                          value: '$_weeklyWorkouts',
                          unit: 'sessions',
                          icon: Icons.bolt,
                          color: const Color(0xFF2196F3),
                          cardColor: cardColor,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── WEEKLY ACTIVITY ───────────────────
                  _SectionLabel(
                      label: 'WEEKLY ACTIVITY',
                      color: secondaryText),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        const days = [
                          'M', 'T', 'W', 'T', 'F', 'S', 'S'
                        ];
                        final isActive =
                            _weeklyActivity[index];
                        return Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.orange
                                    : isDark
                                        ? AppTheme.darkCardLight
                                        : AppTheme.lightCardLight,
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.orange
                                      : borderColor,
                                ),
                              ),
                              child: Icon(
                                isActive
                                    ? Icons.check
                                    : Icons.remove,
                                color: isActive
                                    ? Colors.white
                                    : secondaryText,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[index],
                              style: TextStyle(
                                color: isActive
                                    ? AppTheme.orange
                                    : secondaryText,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── PERSONAL RECORDS ──────────────────
                  _SectionLabel(
                      label: 'PERSONAL RECORDS',
                      color: secondaryText),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: _personalRecords.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No records yet.\nLog a workout with weight to set one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _personalRecords.length,
                            separatorBuilder: (_, __) =>
                                Divider(
                                    height: 1,
                                    color: borderColor),
                            itemBuilder: (context, index) {
                              final record =
                                  _personalRecords[index];
                              return Padding(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 16,
                                    vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.amber
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            record[
                                                'exercise_name'],
                                            style: TextStyle(
                                                color: primaryText,
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            record['record_type'],
                                            style: TextStyle(
                                                color:
                                                    secondaryText,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${record['record_value']}',
                                      style: const TextStyle(
                                        color: AppTheme.orange,
                                        fontWeight:
                                            FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // ── WORKOUT HISTORY ───────────────────
                  _SectionLabel(
                      label: 'WORKOUT HISTORY',
                      color: secondaryText),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: _workoutHistory.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No workouts logged yet.\nTap an exercise in the Library!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _workoutHistory.length,
                            separatorBuilder: (_, __) =>
                                Divider(
                                    height: 1,
                                    color: borderColor),
                            itemBuilder: (context, index) {
                              final log =
                                  _workoutHistory[index];
                              final weight = log['weight'];
                              return Padding(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 16,
                                    vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppTheme.orange
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          log['exercise_name']
                                              .toString()
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: AppTheme.orange,
                                            fontWeight:
                                                FontWeight.w900,
                                            fontSize: 16,
                                          ),
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
                                            log['exercise_name'],
                                            style: TextStyle(
                                                color: primaryText,
                                                fontWeight:
                                                    FontWeight.w700,
                                                fontSize: 15),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${log['sets']} sets × ${log['reps']} reps'
                                            '${weight != null ? ' • ${weight}lbs' : ''}',
                                            style: TextStyle(
                                                color: secondaryText,
                                                fontSize: 13),
                                          ),
                                          if (log['notes'] !=
                                                  null &&
                                              log['notes']
                                                  .toString()
                                                  .isNotEmpty)
                                            Text(
                                              log['notes'],
                                              style: TextStyle(
                                                  color:
                                                      secondaryText,
                                                  fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatDate(
                                          log['logged_at']),
                                      style: TextStyle(
                                          color: secondaryText,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // ── PROGRESS PHOTOS ───────────────────
                  _SectionLabel(
                      label: 'PROGRESS PHOTOS',
                      color: secondaryText),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const ProgressPhotosScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
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
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppTheme.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROGRESS PHOTOS',
                                  style: TextStyle(
                                    color: primaryText,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Track your transformation over time',
                                  style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppTheme.orange, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.cardColor,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          Text(unit,
              style: TextStyle(
                  color: secondaryText, fontSize: 11)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2));
  }
}