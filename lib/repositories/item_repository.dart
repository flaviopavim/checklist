import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/item.dart';

class ItemRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Item>> getAllItems() async {
    final db = await _dbHelper.database;
    final maps = await db.query('items', orderBy: 'name COLLATE NOCASE ASC');
    return maps.map((m) => Item.fromMap(m)).toList();
  }

  Future<Item?> getItemById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Item.fromMap(maps.first);
  }

  Future<void> insertItem(Item item) async {
    final db = await _dbHelper.database;
    await db.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(Item item) async {
    final db = await _dbHelper.database;
    await db.update('items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'items',
      distinct: true,
      columns: ['category'],
      where: 'category IS NOT NULL AND category != ""',
      orderBy: 'category COLLATE NOCASE ASC',
    );
    return maps.map((m) => m['category'] as String).toList();
  }
}
