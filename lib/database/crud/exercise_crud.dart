import '../database_helper.dart';
import '../schema.dart';

class ExerciseCrud {
  final db = DatabaseHelper.instance;

  // READ ALL
  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final database = await db.database;
    return await database.query(DBSchema.tableExercises, orderBy: 'name ASC');
  }

  // FILTER by muscle group, equipment, difficulty
  Future<List<Map<String, dynamic>>> filterExercises({
    String? muscleGroup,
    String? equipment,
    String? difficulty,
  }) async {
    final database = await db.database;
    String where = '';
    List<dynamic> args = [];

    if (muscleGroup != null) {
      where += 'muscle_group = ?';
      args.add(muscleGroup);
    }
    if (equipment != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'equipment = ?';
      args.add(equipment);
    }
    if (difficulty != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'difficulty = ?';
      args.add(difficulty);
    }

    return await database.query(
      DBSchema.tableExercises,
      where: where.isNotEmpty ? where : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'name ASC',
    );
  }

  // SEARCH by name
  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableExercises,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  // INSERT custom exercise
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final database = await db.database;
    return await database.insert(DBSchema.tableExercises, exercise);
  }
}