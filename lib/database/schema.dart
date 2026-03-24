/// Defines all SQLite table names and CREATE TABLE statements
/// for the Fitness Quest database
class DBSchema {
  // ── TABLE NAMES ─────────────────────────────────────────
  static const String tableQuests = 'quests';
  static const String tableExercises = 'exercises';
  static const String tableWorkoutLogs = 'workout_logs';
  static const String tablePersonalRecords =
      'personal_records';
  static const String tableProgressPhotos =
      'progress_photos';
  static const String tableBodyMeasurements =
      'body_measurements';

  /// Stores user-created workout challenges with
  /// duration, weekly goals and active status
  static const String createQuestsTable = '''
    CREATE TABLE $tableQuests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      duration_weeks INTEGER NOT NULL,
      weekly_goal INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL
    )
  ''';

  /// Stores the built-in exercise library with
  /// muscle group, equipment and difficulty info
  static const String createExercisesTable = '''
    CREATE TABLE $tableExercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      muscle_group TEXT NOT NULL,
      equipment TEXT,
      difficulty TEXT NOT NULL,
      description TEXT
    )
  ''';

  /// Logs each completed workout session with
  /// sets, reps, optional weight and notes
  static const String createWorkoutLogsTable = '''
    CREATE TABLE $tableWorkoutLogs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      quest_id INTEGER,
      exercise_id INTEGER NOT NULL,
      sets INTEGER NOT NULL,
      reps INTEGER NOT NULL,
      weight REAL,
      logged_at TEXT NOT NULL,
      notes TEXT,
      FOREIGN KEY (quest_id) REFERENCES $tableQuests(id),
      FOREIGN KEY (exercise_id) REFERENCES $tableExercises(id)
    )
  ''';

  /// Tracks personal bests per exercise
  /// e.g. max weight lifted for a given movement
  static const String createPersonalRecordsTable = '''
    CREATE TABLE $tablePersonalRecords (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exercise_id INTEGER NOT NULL,
      record_value REAL NOT NULL,
      record_type TEXT NOT NULL,
      achieved_at TEXT NOT NULL,
      FOREIGN KEY (exercise_id) REFERENCES $tableExercises(id)
    )
  ''';

  /// Stores file paths and captions for
  /// user progress photos on the timeline
  static const String createProgressPhotosTable = '''
    CREATE TABLE $tableProgressPhotos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      photo_path TEXT NOT NULL,
      caption TEXT,
      taken_at TEXT NOT NULL
    )
  ''';

  /// Stores weekly body weight and BMI measurements
  /// Used for trend charts and goal progress tracking
  static const String createBodyMeasurementsTable = '''
    CREATE TABLE $tableBodyMeasurements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      weight_kg REAL NOT NULL,
      height_cm REAL NOT NULL,
      bmi REAL NOT NULL,
      logged_at TEXT NOT NULL,
      notes TEXT
    )
  ''';
}