import 'package:flutter/material.dart';
import '../services/ai_trainer_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AITrainerScreen extends StatefulWidget {
  const AITrainerScreen({super.key});

  @override
  State<AITrainerScreen> createState() => _AITrainerScreenState();
}

class _AITrainerScreenState extends State<AITrainerScreen> {
  final AITrainerService _trainer = AITrainerService.instance;

  List<AIRecommendation> _recommendations = [];
  Map<String, String> _dailyQuote = {};
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final recs = await _trainer.getRecommendations();
      final quote = _trainer.getDailyQuote();
      setState(() {
        _recommendations = recs;
        _dailyQuote = quote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.instance.sendMotivationalQuote();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motivational notification sent!'),
          backgroundColor: AppTheme.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;
    final primaryText =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final secondaryText =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI TRAINER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orange))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ── DAILY QUOTE ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.orange, AppTheme.orangeDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '💬',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'QUOTE OF THE DAY',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${_dailyQuote['quote']}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '— ${_dailyQuote['author']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── NOTIFICATIONS TOGGLE ─────────────────
                _SectionLabel(
                    label: 'NOTIFICATIONS', color: secondaryText),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active,
                                  color: AppTheme.orange, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Daily Motivation',
                                      style: TextStyle(
                                          color: primaryText,
                                          fontWeight: FontWeight.w700)),
                                  Text('4x daily quotes from the pros',
                                      style: TextStyle(
                                          color: secondaryText,
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) async {
                              setState(
                                  () => _notificationsEnabled = value);
                              if (value) {
                                await NotificationService.instance
                                    .scheduleMotivationalNotifications();
                              } else {
                                await NotificationService.instance
                                    .cancelAll();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _testNotification,
                          icon: const Icon(Icons.send, size: 16),
                          label: const Text('SEND TEST NOTIFICATION'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── RECOMMENDATIONS ──────────────────────
                _SectionLabel(
                    label: 'YOUR RECOMMENDATIONS',
                    color: secondaryText),
                const SizedBox(height: 10),

                ..._recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecommendationCard(
                        recommendation: rec,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                    )),

                const SizedBox(height: 20),

                // ── HOW IT WORKS ─────────────────────────
                _SectionLabel(
                    label: 'HOW IT WORKS', color: secondaryText),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _HowItWorksRow(
                        icon: '🎯',
                        title: 'Muscle Recovery Tracking',
                        description:
                            'Analyzes your recent logs to suggest which muscle group to train next based on recovery time.',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      Divider(color: borderColor),
                      _HowItWorksRow(
                        icon: '⚠️',
                        title: 'Overwork Detection',
                        description:
                            'Warns you when you\'ve trained the same muscle group too frequently, reducing injury risk.',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      Divider(color: borderColor),
                      _HowItWorksRow(
                        icon: '😴',
                        title: 'Rest Day Intelligence',
                        description:
                            'Recommends rest or active recovery days when your streak indicates fatigue risk.',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      Divider(color: borderColor),
                      _HowItWorksRow(
                        icon: '📈',
                        title: 'Goal Progress Nudges',
                        description:
                            'Keeps you on track by monitoring your weekly goal and alerting you when you\'re falling behind.',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// Recommendation card
class _RecommendationCard extends StatelessWidget {
  final AIRecommendation recommendation;
  final Color cardColor;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;

  const _RecommendationCard({
    required this.recommendation,
    required this.cardColor,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rec.color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rec.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(rec.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rec.title,
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rec.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rec.type.name.toUpperCase(),
                        style: TextStyle(
                          color: rec.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rec.message,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// How it works row
class _HowItWorksRow extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final Color primaryText;
  final Color secondaryText;

  const _HowItWorksRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(description,
                    style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section label
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}