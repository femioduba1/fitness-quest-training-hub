import 'package:flutter/material.dart';

// This screen shows the user's workout progress and basic analytics.
// Right now it's using placeholder data, but it’s structured so it can
// easily connect to real data from SQLite later.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
      ),
      body: ListView(
        // Using ListView so the screen can scroll if more data is added later
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: const [

          // These cards show key stats like streak, workouts, and hours trained
          _ProgressStatCard(
            title: 'Current Streak',
            value: '5 days',
            icon: Icons.local_fire_department,
          ),
          SizedBox(height: 12),

          _ProgressStatCard(
            title: 'Completed Workouts',
            value: '18',
            icon: Icons.check_circle,
          ),
          SizedBox(height: 12),

          _ProgressStatCard(
            title: 'Hours Trained',
            value: '12.5 hrs',
            icon: Icons.timer,
          ),

          SizedBox(height: 24),

          // Section for weekly activity (will later display a chart)
          _WeeklyActivityCard(),

          SizedBox(height: 16),

          // Section for tracking progress photos over time
          _ProgressPhotosCard(),
        ],
      ),
    );
  }
}

// Reusable stat card used to display key metrics like streak, workouts, etc.
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// This card represents the weekly activity section
// Right now it's just a placeholder, but it’s where charts/graphs would go
class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  // Placeholder text so we can plug in real chart data later
                  'Chart placeholder\nPartner can connect live data here later.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This card is meant for progress photos over time
// Could be used to show visual transformations or checkpoints
class _ProgressPhotosCard extends StatelessWidget {
  const _ProgressPhotosCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Progress Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Photo timeline placeholder',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}