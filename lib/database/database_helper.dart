import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';

/// Singleton database helper that manages SQLite initialization,
/// versioning, and provides a shared database instance
class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._internal();
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
      version: 2, // Bumped to 2 for new exercises
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all tables and seeds exercises on first launch
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DBSchema.createQuestsTable);
    await db.execute(DBSchema.createExercisesTable);
    await db.execute(DBSchema.createWorkoutLogsTable);
    await db.execute(DBSchema.createPersonalRecordsTable);
    await db.execute(DBSchema.createProgressPhotosTable);
    await _seedExercises(db);
  }

  /// Handles database upgrades between versions
  Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Clear old exercises and re-seed with full list
      await db.delete(DBSchema.tableExercises);
      await _seedExercises(db);
    }
  }

  /// Seeds 60+ exercises across 6 muscle groups
  Future<void> _seedExercises(Database db) async {
    final exercises = [

      // ── CHEST (10 exercises) ──────────────────────────
      {'name': 'Bench Press', 'muscle_group': 'Chest', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Classic barbell chest press on a flat bench'},
      {'name': 'Push-Up', 'muscle_group': 'Chest', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Classic bodyweight chest exercise'},
      {'name': 'Incline Bench Press', 'muscle_group': 'Chest', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Upper chest focused press on incline bench'},
      {'name': 'Decline Bench Press', 'muscle_group': 'Chest', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Lower chest focused press on decline bench'},
      {'name': 'Dumbbell Flyes', 'muscle_group': 'Chest', 'equipment': 'Dumbbells', 'difficulty': 'Intermediate', 'description': 'Chest isolation exercise with dumbbells'},
      {'name': 'Cable Crossover', 'muscle_group': 'Chest', 'equipment': 'Cable Machine', 'difficulty': 'Intermediate', 'description': 'Cable chest fly for inner chest definition'},
      {'name': 'Chest Dip', 'muscle_group': 'Chest', 'equipment': 'Dip Bar', 'difficulty': 'Intermediate', 'description': 'Bodyweight dip targeting lower chest'},
      {'name': 'Incline Dumbbell Press', 'muscle_group': 'Chest', 'equipment': 'Dumbbells', 'difficulty': 'Intermediate', 'description': 'Upper chest press with dumbbells on incline'},
      {'name': 'Pec Deck Machine', 'muscle_group': 'Chest', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Machine chest fly for isolation'},
      {'name': 'Wide Push-Up', 'muscle_group': 'Chest', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Wide grip push-up targeting outer chest'},

      // ── BACK (10 exercises) ───────────────────────────
      {'name': 'Pull-Up', 'muscle_group': 'Back', 'equipment': 'Pull-up Bar', 'difficulty': 'Intermediate', 'description': 'Upper body pulling exercise for back width'},
      {'name': 'Deadlift', 'muscle_group': 'Back', 'equipment': 'Barbell', 'difficulty': 'Advanced', 'description': 'Full body compound lift targeting lower back'},
      {'name': 'Bent Over Row', 'muscle_group': 'Back', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Barbell row for overall back thickness'},
      {'name': 'Lat Pulldown', 'muscle_group': 'Back', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Cable pulldown for back width'},
      {'name': 'Seated Cable Row', 'muscle_group': 'Back', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Cable row for mid back thickness'},
      {'name': 'T-Bar Row', 'muscle_group': 'Back', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Heavy rowing for back mass'},
      {'name': 'Single Arm Dumbbell Row', 'muscle_group': 'Back', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Unilateral row for back imbalances'},
      {'name': 'Face Pull', 'muscle_group': 'Back', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Rear delt and upper back exercise'},
      {'name': 'Hyperextension', 'muscle_group': 'Back', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Lower back strengthening exercise'},
      {'name': 'Chin-Up', 'muscle_group': 'Back', 'equipment': 'Pull-up Bar', 'difficulty': 'Intermediate', 'description': 'Underhand grip pull-up for back and biceps'},

      // ── LEGS (10 exercises) ───────────────────────────
      {'name': 'Squat', 'muscle_group': 'Legs', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'King of leg exercises — quad dominant'},
      {'name': 'Lunges', 'muscle_group': 'Legs', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Unilateral leg exercise for balance and strength'},
      {'name': 'Leg Press', 'muscle_group': 'Legs', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Machine compound leg press'},
      {'name': 'Romanian Deadlift', 'muscle_group': 'Legs', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Hip hinge for hamstrings and glutes'},
      {'name': 'Leg Curl', 'muscle_group': 'Legs', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Hamstring isolation on machine'},
      {'name': 'Leg Extension', 'muscle_group': 'Legs', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Quad isolation on machine'},
      {'name': 'Calf Raise', 'muscle_group': 'Legs', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Calf muscle isolation exercise'},
      {'name': 'Bulgarian Split Squat', 'muscle_group': 'Legs', 'equipment': 'Dumbbells', 'difficulty': 'Advanced', 'description': 'Rear foot elevated split squat'},
      {'name': 'Hack Squat', 'muscle_group': 'Legs', 'equipment': 'Machine', 'difficulty': 'Intermediate', 'description': 'Machine squat for quad development'},
      {'name': 'Sumo Deadlift', 'muscle_group': 'Legs', 'equipment': 'Barbell', 'difficulty': 'Advanced', 'description': 'Wide stance deadlift targeting inner thighs'},

      // ── CORE (10 exercises) ───────────────────────────
      {'name': 'Plank', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Isometric core stabilization hold'},
      {'name': 'Crunches', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Basic abdominal crunch exercise'},
      {'name': 'Russian Twist', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Rotational core exercise for obliques'},
      {'name': 'Leg Raises', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Lower ab focused leg raise'},
      {'name': 'Ab Wheel Rollout', 'muscle_group': 'Core', 'equipment': 'Ab Wheel', 'difficulty': 'Advanced', 'description': 'Full core extension with ab wheel'},
      {'name': 'Bicycle Crunches', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Beginner', 'description': 'Alternating elbow to knee crunch'},
      {'name': 'Mountain Climbers', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Dynamic plank with knee drives'},
      {'name': 'Side Plank', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Lateral core stabilization hold'},
      {'name': 'Dead Bug', 'muscle_group': 'Core', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Anti-extension core stability exercise'},
      {'name': 'Hanging Knee Raise', 'muscle_group': 'Core', 'equipment': 'Pull-up Bar', 'difficulty': 'Intermediate', 'description': 'Hanging lower ab exercise'},

      // ── ARMS (10 exercises) ───────────────────────────
      {'name': 'Bicep Curl', 'muscle_group': 'Arms', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Classic dumbbell bicep curl'},
      {'name': 'Hammer Curl', 'muscle_group': 'Arms', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Neutral grip curl for brachialis'},
      {'name': 'Preacher Curl', 'muscle_group': 'Arms', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Supported curl for peak bicep'},
      {'name': 'Concentration Curl', 'muscle_group': 'Arms', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Seated isolation curl for bicep peak'},
      {'name': 'Tricep Pushdown', 'muscle_group': 'Arms', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Cable tricep isolation exercise'},
      {'name': 'Skull Crushers', 'muscle_group': 'Arms', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Lying tricep extension for mass'},
      {'name': 'Overhead Tricep Extension', 'muscle_group': 'Arms', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Overhead dumbbell tricep extension'},
      {'name': 'Diamond Push-Up', 'muscle_group': 'Arms', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Close grip push-up for triceps'},
      {'name': 'Cable Curl', 'muscle_group': 'Arms', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Cable bicep curl for constant tension'},
      {'name': 'Close Grip Bench Press', 'muscle_group': 'Arms', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Narrow grip bench for tricep mass'},

      // ── SHOULDERS (10 exercises) ──────────────────────
      {'name': 'Overhead Press', 'muscle_group': 'Shoulders', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Standing barbell shoulder press'},
      {'name': 'Lateral Raise', 'muscle_group': 'Shoulders', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Side delt isolation with dumbbells'},
      {'name': 'Front Raise', 'muscle_group': 'Shoulders', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Front delt raise with dumbbells'},
      {'name': 'Arnold Press', 'muscle_group': 'Shoulders', 'equipment': 'Dumbbells', 'difficulty': 'Intermediate', 'description': 'Rotating dumbbell press for all three delts'},
      {'name': 'Rear Delt Fly', 'muscle_group': 'Shoulders', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Bent over fly for rear deltoid'},
      {'name': 'Upright Row', 'muscle_group': 'Shoulders', 'equipment': 'Barbell', 'difficulty': 'Intermediate', 'description': 'Barbell row to chin for side delts'},
      {'name': 'Cable Lateral Raise', 'muscle_group': 'Shoulders', 'equipment': 'Cable Machine', 'difficulty': 'Beginner', 'description': 'Cable side raise for constant tension'},
      {'name': 'Shrugs', 'muscle_group': 'Shoulders', 'equipment': 'Dumbbells', 'difficulty': 'Beginner', 'description': 'Trap exercise with dumbbell shrugs'},
      {'name': 'Machine Shoulder Press', 'muscle_group': 'Shoulders', 'equipment': 'Machine', 'difficulty': 'Beginner', 'description': 'Guided machine overhead press'},
      {'name': 'Pike Push-Up', 'muscle_group': 'Shoulders', 'equipment': 'None', 'difficulty': 'Intermediate', 'description': 'Bodyweight shoulder press variation'},
    ];

    for (var exercise in exercises) {
      await db.insert(DBSchema.tableExercises, exercise);
    }
  }
}