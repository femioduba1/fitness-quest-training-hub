import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../database/crud/workout_log_crud.dart';
import '../services/streak_service.dart';
import '../services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuestCrud _questCrud = QuestCrud();
  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final StreakService _streakService = StreakService.instance;
  final PreferencesService _prefsService = PreferencesService.instance;

  List<Map<String, dynamic>> _activeQuests = [];
  int _currentStreak = 0;
  int _weeklyWorkouts = 0;
  String _userName = 'Athlete';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // Loads all data needed for the dashboard
  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      // Load everything in parallel for speed
      final results = await Future.wait([
        _questCrud.getActiveQuests(),
        _streakService.getCurrentStreak(),
        _logCrud.getWeeklyWorkoutCount(),
        _prefsService.getUserName(),
      ]);

      setState(() {
        _activeQuests = results[0] as List<Map<String, dynamic>>;
        _currentStreak = results[1] as int;
        _weeklyWorkouts = results[2] as int;
        _userName = results[3] as String;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calculates quest progress based on logs vs weekly goal
  double _calculateProgress(Map<String, dynamic> quest) {
    final durationWeeks = quest['duration_weeks'] as int;
    final weeklyGoal = quest['weekly_goal'] as int;
    final totalGoal = durationWeeks * weeklyGoal;
    if (totalGoal == 0) return 0.0;
    // Clamp between 0 and 1
    return (_weeklyWorkouts / totalGoal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        // Refresh button to reload dashboard manually
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _activeQuests.isEmpty
                  // Empty state — no quests yet
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center, size: 50),
                          const SizedBox(height: 10),
                          const Text(
                            'No quests yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Create your first workout quest'),
                        ],
                      ),
                    )
                  // Dashboard content
                  : ListView(
                      children: [

                        // Welcome banner
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $_userName!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Track your workout goals, stay consistent, and build momentum.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Stats row — now pulling real data
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Active Quests',
                                value: '${_activeQuests.length}',
                                icon: Icons.flag,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'This Week',
                                value: '$_weeklyWorkouts',
                                icon: Icons.local_fire_department,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Streak',
                                value: '🔥 $_currentStreak',
                                icon: Icons.bolt,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Current Workout Quests',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Real quest cards from SQLite
                        ..._activeQuests.map((quest) {
                          final progress = _calculateProgress(quest);
                          final progressPercent = (progress * 100).toInt();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuestCard(
                              title: quest['name'],
                              subtitle:
                                  '${quest['description'] ?? 'No description'} • ${quest['duration_weeks']} weeks',
                              progress: progress,
                              progressText: '$progressPercent% complete',
                            ),
                          );
                        }),
                      ],
                    ),
            ),
    );
  }
}

// Reusable stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Quest card widget
class _QuestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String progressText;

  const _QuestCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 8),
            Text(progressText),
          ],
        ),
      ),
    );
  }
}