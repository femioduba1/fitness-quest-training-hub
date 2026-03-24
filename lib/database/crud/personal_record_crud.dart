import '../database_helper.dart';
import '../schema.dart';

class PersonalRecordCrud {
  final db = DatabaseHelper.instance;

  // CREATE
  Future<int> insertRecord(Map<String, dynamic> record) async {
    final database = await db.database;
    record['achieved_at'] = DateTime.now().toIso8601String();
    return await database.insert(DBSchema.tablePersonalRecords, record);
  }

  // READ ALL RECORDS FOR AN EXERCISE
  Future<List<Map<String, dynamic>>> getRecordsForExercise(int exerciseId) async {
    final database = await db.database;
    return await database.query(
      DBSchema.tablePersonalRecords,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'achieved_at DESC',
    );
  }

  // READ BEST RECORD FOR AN EXERCISE
  Future<Map<String, dynamic>?> getBestRecord(int exerciseId) async {
    final database = await db.database;
    final result = await database.query(
      DBSchema.tablePersonalRecords,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'record_value DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // DELETE
  Future<int> deleteRecord(int id) async {
    final database = await db.database;
    return await database.delete(
      DBSchema.tablePersonalRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}