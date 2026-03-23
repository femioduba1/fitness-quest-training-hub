class DBSchema {
  // Table names
  static const String tableQuests = 'quests';
  static const String tableExercises = 'exercises';
  static const String tableWorkoutLogs = 'workout_logs';
  static const String tablePersonalRecords = 'personal_records';
  static const String tableProgressPhotos = 'progress_photos';

  // QUESTS table
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

  // EXERCISES table
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

  // WORKOUT LOGS table
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

  // PERSONAL RECORDS table
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

  // PROGRESS PHOTOS table
  static const String createProgressPhotosTable = '''
    CREATE TABLE $tableProgressPhotos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      photo_path TEXT NOT NULL,
      caption TEXT,
      taken_at TEXT NOT NULL
    )
  ''';
}