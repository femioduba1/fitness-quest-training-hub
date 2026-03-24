import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../schema.dart';

class WorkoutLogCrud {
  final db = DatabaseHelper.instance;

  // CREATE
  Future<int> insertLog(Map<String, dynamic> log) async {
    final database = await db.database;
    log['logged_at'] = DateTime.now().toIso8601String();
    return await database.insert(DBSchema.tableWorkoutLogs, log);
  }

  // READ ALL LOGS
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableWorkoutLogs,
      orderBy: 'logged_at DESC',
    );
  }

  // READ LOGS FOR A SPECIFIC QUEST
  Future<List<Map<String, dynamic>>> getLogsByQuest(int questId) async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableWorkoutLogs,
      where: 'quest_id = ?',
      whereArgs: [questId],
      orderBy: 'logged_at DESC',
    );
  }

  // READ LOGS FOR TODAY (used for streak tracking)
  Future<List<Map<String, dynamic>>> getTodaysLogs() async {
    final database = await db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await database.query(
      DBSchema.tableWorkoutLogs,
      where: 'logged_at LIKE ?',
      whereArgs: ['$today%'],
    );
  }

  // COUNT DISTINCT WORKOUT DAYS THIS WEEK (used for home dashboard)
  Future<int> getWeeklyWorkoutCount() async {
    final database = await db.database;
    final monday = _getThisMonday();
    final result = await database.rawQuery(
      '''
      SELECT COUNT(DISTINCT date(logged_at)) as count
      FROM ${DBSchema.tableWorkoutLogs}
      WHERE logged_at >= ?
    ''',
      [monday],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // DELETE
  Future<int> deleteLog(int id) async {
    final database = await db.database;
    return await database.delete(
      DBSchema.tableWorkoutLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // HELPER — gets the date of this week's Monday
  String _getThisMonday() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  // GET ALL LOGS WITH EXERCISE NAMES (for display)
  Future<List<Map<String, dynamic>>> getLogsWithExerciseNames() async {
    final database = await db.database;
    return await database.rawQuery('''
    SELECT 
      wl.id,
      wl.sets,
      wl.reps,
      wl.weight,
      wl.notes,
      wl.logged_at,
      e.name as exercise_name,
      e.muscle_group
    FROM ${DBSchema.tableWorkoutLogs} wl
    INNER JOIN ${DBSchema.tableExercises} e ON wl.exercise_id = e.id
    ORDER BY wl.logged_at DESC
  ''');
  }
}
