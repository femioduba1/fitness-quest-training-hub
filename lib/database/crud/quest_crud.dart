import '../database_helper.dart';
import '../schema.dart';

class QuestCrud {
  final db = DatabaseHelper.instance;

  // CREATE
  Future<int> insertQuest(Map<String, dynamic> quest) async {
    final database = await db.database;
    quest['created_at'] = DateTime.now().toIso8601String();
    return await database.insert(DBSchema.tableQuests, quest);
  }

  // READ ALL
  Future<List<Map<String, dynamic>>> getAllQuests() async {
    final database = await db.database;
    return await database.query(DBSchema.tableQuests, orderBy: 'created_at DESC');
  }

  // READ ONE
  Future<Map<String, dynamic>?> getQuestById(int id) async {
    final database = await db.database;
    final result = await database.query(
      DBSchema.tableQuests,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // READ ACTIVE QUESTS ONLY
  Future<List<Map<String, dynamic>>> getActiveQuests() async {
    final database = await db.database;
    return await database.query(
      DBSchema.tableQuests,
      where: 'is_active = ?',
      whereArgs: [1],
    );
  }

  // UPDATE
  Future<int> updateQuest(int id, Map<String, dynamic> updatedData) async {
    final database = await db.database;
    return await database.update(
      DBSchema.tableQuests,
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteQuest(int id) async {
    final database = await db.database;
    return await database.delete(
      DBSchema.tableQuests,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}