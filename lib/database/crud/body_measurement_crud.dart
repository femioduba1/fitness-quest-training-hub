import '../database_helper.dart';
import '../schema.dart';

/// CRUD operations for body weight and BMI measurements
/// Used to track weight trends and calculate BMI over time
class BodyMeasurementCrud {
  final db = DatabaseHelper.instance;

  /// Inserts a new body measurement with auto timestamp
  Future<int> insertMeasurement(
      Map<String, dynamic> measurement) async {
    final database = await db.database;
    measurement['logged_at'] =
        DateTime.now().toIso8601String();
    return await database.insert(
        DBSchema.tableBodyMeasurements, measurement);
  }

  /// Returns all measurements ordered newest first
  Future<List<Map<String, dynamic>>>
      getAllMeasurements() async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableBodyMeasurements,
      orderBy: 'logged_at DESC',
    );
  }

  /// Returns measurements from the past 30 days
  /// Used for the monthly weight trend chart
  Future<List<Map<String, dynamic>>>
      getLastMonthMeasurements() async {
    final database = await db.database;
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    return await database.query(
      DBSchema.tableBodyMeasurements,
      where: 'logged_at >= ?',
      whereArgs: [thirtyDaysAgo],
      orderBy: 'logged_at ASC',
    );
  }

  /// Returns the most recent measurement
  Future<Map<String, dynamic>?> getLatestMeasurement() async {
    final database = await db.database;
    final result = await database.query(
      DBSchema.tableBodyMeasurements,
      orderBy: 'logged_at DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Returns measurements grouped by week for trend analysis
  Future<List<Map<String, dynamic>>>
      getWeeklyAverages() async {
    final database = await db.database;
    return await database.rawQuery('''
      SELECT 
        strftime('%Y-%W', logged_at) as week,
        AVG(weight_kg) as avg_weight,
        AVG(bmi) as avg_bmi,
        MIN(logged_at) as week_start
      FROM ${DBSchema.tableBodyMeasurements}
      GROUP BY strftime('%Y-%W', logged_at)
      ORDER BY logged_at ASC
    ''');
  }

  /// Deletes a measurement by ID
  Future<int> deleteMeasurement(int id) async {
    final database = await db.database;
    return await database.delete(
      DBSchema.tableBodyMeasurements,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}