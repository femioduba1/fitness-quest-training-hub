import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_quest.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DBSchema.createQuestsTable);
    await db.execute(DBSchema.createExercisesTable);
    await db.execute(DBSchema.createWorkoutLogsTable);
    await db.execute(DBSchema.createPersonalRecordsTable);
    await db.execute(DBSchema.createProgressPhotosTable);
    await _seedExercises(db); // Pre-load exercise library
  }

  // Seed some starter exercises into the library
  Future<void> _seedExercises(Database db) async {
    final exercises = [
      {'name': 'Push-Up', 'muscle_group': 'Chest', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Classic bodyweight chest exercise'},
      {'name': 'Squat', 'muscle_group': 'Legs', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Fundamental lower body movement'},
      {'name': 'Pull-Up', 'muscle_group': 'Back', 'equipment': 'Pull-up Bar', 'difficulty': 'Intermediate', 'description': 'Upper body pulling exercise'},
      {'name': 'Plank', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Core stabilization hold'},
      {'name': 'Deadlift', 'muscle_group': 'Back', 'equipment': 'Barbell', 'difficulty': 'Advanced', 'description': 'Full body compound lift'},
      {'name': 'Bench Press', 'muscle_group': 'Chest', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Barbell chest press'},
      {'name': 'Lunges', 'muscle_group': 'Legs', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Unilateral leg exercise'},
      {'name': 'Bicep Curl', 'muscle_group': 'Arms', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Isolation curl for biceps'},
    ];

    for (var exercise in exercises) {
      await db.insert(DBSchema.tableExercises, exercise);
    }
  }
}