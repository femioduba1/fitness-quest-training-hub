import 'package:flutter/material.dart';
import '../database/crud/quest_crud.dart';
import '../database/crud/workout_log_crud.dart';
import '../services/streak_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

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

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
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
    }
  }

  double _calculateProgress(Map<String, dynamic> quest) {
    final durationWeeks = quest['duration_weeks'] as int;
    final weeklyGoal = quest['weekly_goal'] as int;
    final totalGoal = durationWeeks * weeklyGoal;
    if (totalGoal == 0) return 0.0;
    return (_weeklyWorkouts / totalGoal).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orange))
          : CustomScrollView(
              slivers: [
                // ── SLIVER APP BAR ───────────────────────────
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppTheme.background,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadDashboard,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6000),
                            Color(0xFFCC4D00),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── STATS ROW ────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'STREAK',
                              value: '$_currentStreak',
                              unit: 'days',
                              icon: Icons.local_fire_department,
                              color: AppTheme.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'THIS WEEK',
                              value: '$_weeklyWorkouts',
                              unit: 'workouts',
                              icon: Icons.bolt,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'QUESTS',
                              value: '${_activeQuests.length}',
                              unit: 'active',
                              icon: Icons.flag,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── ACTIVE QUESTS ────────────────────────
                      const Text(
                        'ACTIVE QUESTS',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_activeQuests.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.flag_outlined,
                                  size: 48, color: AppTheme.textSecondary),
                              SizedBox(height: 12),
                              Text(
                                'NO ACTIVE QUESTS',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Create your first quest to get started',
                                style:
                                    TextStyle(color: AppTheme.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._activeQuests.map((quest) {
                          final progress = _calculateProgress(quest);
                          final progressPercent = (progress * 100).toInt();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuestCard(
                              title: quest['name'],
                              subtitle:
                                  '${quest['duration_weeks']} weeks • ${quest['weekly_goal']}x/week',
                              progress: progress,
                              progressText: '$progressPercent%',
                            ),
                          );
                        }),
                    ]),
                  ),
                ),
              ],
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  progressText,
                  style: const TextStyle(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.cardBackgroundLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.orange),
            ),
          ),
        ],
      ),
    );
  }
}