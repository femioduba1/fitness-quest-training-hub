import '../database_helper.dart';
import '../schema.dart';

class ProgressPhotoCrud {
  final db = DatabaseHelper.instance;

  // CREATE
  Future<int> insertPhoto(Map<String, dynamic> photo) async {
    final database = await db.database;
    photo['taken_at'] = DateTime.now().toIso8601String();
    return await database.insert(
        DBSchema.tableProgressPhotos, photo);
  }

  // READ ALL — chronological order
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableProgressPhotos,
      orderBy: 'taken_at DESC',
    );
  }

  // READ BY MONTH — for grouping
  Future<Map<String, List<Map<String, dynamic>>>>
      getPhotosByMonth() async {
    final photos = await getAllPhotos();
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final photo in photos) {
      final date = DateTime.parse(photo['taken_at']);
      final key =
          '${_monthName(date.month)} ${date.year}';
      grouped[key] = grouped[key] ?? [];
      grouped[key]!.add(photo);
    }

    return grouped;
  }

  // UPDATE caption
  Future<int> updateCaption(int id, String caption) async {
    final database = await db.database;
    return await database.update(
      DBSchema.tableProgressPhotos,
      {'caption': caption},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deletePhoto(int id) async {
    final database = await db.database;
    return await database.delete(
      DBSchema.tableProgressPhotos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}