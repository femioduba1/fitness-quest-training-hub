import 'package:flutter/material.dart';
import '../database/crud/workout_log_crud.dart';
import '../database/crud/personal_record_crud.dart';
import '../database/crud/exercise_crud.dart';
import '../services/streak_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
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
  List<Map<String, dynamic>> _exercises = [];
  List<bool> _weeklyActivity = List.filled(7, false);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _streakService.getCurrentStreak(),
        _logCrud.getAllLogs(),
        _logCrud.getWeeklyWorkoutCount(),
        _exerciseCrud.getAllExercises(),
      ]);

      final allLogs = results[1] as List<Map<String, dynamic>>;
      final exercises = results[3] as List<Map<String, dynamic>>;

      // Build weekly activity (Mon–Sun) from logs
      final weeklyActivity = await _buildWeeklyActivity();

      // Load personal records for each exercise
      final List<Map<String, dynamic>> records = [];
      for (final exercise in exercises) {
        final best = await _prCrud.getBestRecord(exercise['id']);
        if (best != null) {
          records.add({
            'exercise_name': exercise['name'],
            'record_value': best['record_value'],
            'record_type': best['record_type'],
            'achieved_at': best['achieved_at'],
          });
        }
      }

      setState(() {
        _currentStreak = results[0] as int;
        _totalWorkouts = allLogs.length;
        _weeklyWorkouts = results[2] as int;
        _exercises = exercises;
        _weeklyActivity = weeklyActivity;
        _personalRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Builds a 7-element list (Mon–Sun) marking which days had a workout
  Future<List<bool>> _buildWeeklyActivity() async {
    final now = DateTime.now();
    final List<bool> activity = List.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      final dayStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final logs = await _logCrud.getTodaysLogs();
      final hasLog = logs.any((log) => log['logged_at'].startsWith(dayStr));
      activity[i] = hasLog;
    }

    return activity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [

                // Streak stat
                _ProgressStatCard(
                  title: 'Current Streak',
                  value: '🔥 $_currentStreak days',
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 12),

                // Total workouts stat
                _ProgressStatCard(
                  title: 'Completed Workouts',
                  value: '$_totalWorkouts',
                  icon: Icons.check_circle,
                ),
                const SizedBox(height: 12),

                // This week stat
                _ProgressStatCard(
                  title: 'Workouts This Week',
                  value: '$_weeklyWorkouts',
                  icon: Icons.timer,
                ),

                const SizedBox(height: 24),

                // Weekly activity chart
                _WeeklyActivityCard(weeklyActivity: _weeklyActivity),

                const SizedBox(height: 16),

                // Personal records section
                _PersonalRecordsCard(records: _personalRecords),

                const SizedBox(height: 16),

                // Progress photos placeholder
                const _ProgressPhotosCard(),
              ],
            ),
    );
  }
}

// Reusable stat card
class _ProgressStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProgressStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Weekly activity card — shows Mon–Sun with filled/empty circles
class _WeeklyActivityCard extends StatelessWidget {
  final List<bool> weeklyActivity;

  const _WeeklyActivityCard({required this.weeklyActivity});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final isActive = weeklyActivity[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isActive
                          ? const Color(0xFF3B82F6)
                          : Colors.grey.shade200,
                      child: Icon(
                        isActive ? Icons.check : Icons.remove,
                        color: isActive ? Colors.white : Colors.grey,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF3B82F6)
                            : Colors.grey,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Personal records card — shows best record per exercise
class _PersonalRecordsCard extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const _PersonalRecordsCard({required this.records});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            records.isEmpty
                ? const Center(
                    child: Text(
                      'No personal records yet.\nLog a workout to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    children: records.map((record) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                        ),
                        title: Text(record['exercise_name']),
                        subtitle: Text(record['record_type']),
                        trailing: Text(
                          '${record['record_value']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// Progress photos placeholder
class _ProgressPhotosCard extends StatelessWidget {
  const _ProgressPhotosCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Progress Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Photo timeline coming soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
