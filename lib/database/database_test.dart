import 'crud/quest_crud.dart';
import 'crud/workout_log_crud.dart';
import 'crud/exercise_crud.dart';
import 'crud/personal_record_crud.dart';

Future<void> runDatabaseTests() async {
  print('=== Starting Database Tests ===');

  // Test Quest CRUD
  final questCrud = QuestCrud();
  final questId = await questCrud.insertQuest({
    'name': 'March Strength Challenge',
    'description': 'Build strength over 4 weeks',
    'duration_weeks': 4,
    'weekly_goal': 4,
    'start_date': DateTime.now().toIso8601String(),
    'is_active': 1,
  });
  print('✅ Quest inserted with ID: $questId');

  final quests = await questCrud.getAllQuests();
  print('✅ Total quests: ${quests.length}');

  // Test Exercise CRUD
  final exerciseCrud = ExerciseCrud();
  final exercises = await exerciseCrud.getAllExercises();
  print('✅ Seeded exercises: ${exercises.length}');

  final filtered = await exerciseCrud.filterExercises(difficulty: 'Beginner');
  print('✅ Beginner exercises: ${filtered.length}');

  final searched = await exerciseCrud.searchExercises('push');
  print('✅ Search results for "push": ${searched.length}');

  // Test Workout Log CRUD
  final logCrud = WorkoutLogCrud();
  final logId = await logCrud.insertLog({
    'quest_id': questId,
    'exercise_id': exercises.first['id'],
    'sets': 3,
    'reps': 15,
    'weight': null,
    'notes': 'Felt strong today',
  });
  print('✅ Workout log inserted with ID: $logId');

  final todaysLogs = await logCrud.getTodaysLogs();
  print('✅ Todays logs: ${todaysLogs.length}');

  // Test Personal Record CRUD
  final prCrud = PersonalRecordCrud();
  final prId = await prCrud.insertRecord({
    'exercise_id': exercises.first['id'],
    'record_value': 50.0,
    'record_type': 'max_reps',
  });
  print('✅ Personal record inserted with ID: $prId');

  final best = await prCrud.getBestRecord(exercises.first['id']);
  print('✅ Best record: ${best?['record_value']}');

  print('=== All Tests Passed ===');
}