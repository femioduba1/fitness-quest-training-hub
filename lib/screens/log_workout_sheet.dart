import 'package:flutter/material.dart';
import '../database/crud/workout_log_crud.dart';
import '../database/crud/personal_record_crud.dart';
import '../database/crud/quest_crud.dart';
import '../services/streak_service.dart';

class LogWorkoutSheet extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const LogWorkoutSheet({super.key, required this.exercise});

  @override
  State<LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends State<LogWorkoutSheet> {
  final WorkoutLogCrud _logCrud = WorkoutLogCrud();
  final PersonalRecordCrud _prCrud = PersonalRecordCrud();
  final QuestCrud _questCrud = QuestCrud();
  final StreakService _streakService = StreakService.instance;

  final TextEditingController _setsController =
      TextEditingController(text: '3');
  final TextEditingController _repsController =
      TextEditingController(text: '10');
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int? _selectedQuestId;
  List<Map<String, dynamic>> _activeQuests = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadActiveQuests();
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveQuests() async {
    final quests = await _questCrud.getActiveQuests();
    setState(() {
      _activeQuests = quests;
      if (quests.isNotEmpty) {
        _selectedQuestId = quests.first['id'];
      }
    });
  }

  Future<void> _saveLog() async {
    // Validate sets and reps
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (sets == null || sets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of sets'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of reps'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final weight = double.tryParse(_weightController.text.trim());

      // Save the workout log
      await _logCrud.insertLog({
        'quest_id': _selectedQuestId,
        'exercise_id': widget.exercise['id'],
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'notes': _notesController.text.trim(),
      });

      // Update streak
      await _streakService.recordWorkoutToday();

      // Check if this is a new personal record
      if (weight != null) {
        final best =
            await _prCrud.getBestRecord(widget.exercise['id']);
        if (best == null || weight > (best['record_value'] as double)) {
          await _prCrud.insertRecord({
            'exercise_id': widget.exercise['id'],
            'record_value': weight,
            'record_type': 'max_weight',
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🏆 New Personal Record!'),
                backgroundColor: Colors.amber,
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // true = workout was logged
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ ${widget.exercise['name']} logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Moves the sheet up when keyboard opens
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),

            Text(
              '${widget.exercise['muscle_group']} • ${widget.exercise['difficulty']}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Quest selector (optional)
            if (_activeQuests.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                value: _selectedQuestId,
                decoration: const InputDecoration(
                  labelText: 'Link to Quest (optional)',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No quest'),
                  ),
                  ..._activeQuests.map((quest) => DropdownMenuItem(
                        value: quest['id'] as int,
                        child: Text(quest['name']),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedQuestId = value);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Sets and Reps row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weight input (optional)
            TextFormField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (optional)',
                prefixIcon: Icon(Icons.fitness_center),
                hintText: 'e.g. 135',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Notes input (optional)
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
                hintText: 'e.g. Felt strong today',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : _saveLog,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Log Workout',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}