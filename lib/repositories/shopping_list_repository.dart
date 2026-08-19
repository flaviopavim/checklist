import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';

class ShoppingListRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<ShoppingList>> getAllLists() async {
    final db = await _dbHelper.database;
    final maps = await db.query('shopping_lists',
        orderBy: 'isActive DESC, createdAt DESC');
    return maps.map((m) => ShoppingList.fromMap(m)).toList();
  }

  Future<ShoppingList?> getActiveList() async {
    final db = await _dbHelper.database;
    final maps = await db.query('shopping_lists',
        where: 'isActive = 1', orderBy: 'createdAt DESC', limit: 1);
    if (maps.isEmpty) return null;
    return ShoppingList.fromMap(maps.first);
  }

  Future<ShoppingList?> getListById(String id) async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('shopping_lists', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ShoppingList.fromMap(maps.first);
  }

  Future<void> insertList(ShoppingList list) async {
    final db = await _dbHelper.database;
    await db.insert('shopping_lists', list.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateList(ShoppingList list) async {
    final db = await _dbHelper.database;
    await db.update('shopping_lists', list.toMap(),
        where: 'id = ?', whereArgs: [list.id]);
  }

  Future<void> deleteList(String id) async {
    final db = await _dbHelper.database;
    await db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ShoppingListItem>> getListItems(String listId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT sli.*, 
        i.id as i_id, i.name as i_name, i.category as i_category, i.unit as i_unit,
        i.defaultQuantity as i_defaultQuantity, i.createdAt as i_createdAt,
        i.lastPurchasedAt as i_lastPurchasedAt, i.averageIntervalDays as i_averageIntervalDays,
        i.purchaseCount as i_purchaseCount, i.icon as i_icon
      FROM shopping_list_items sli
      INNER JOIN items i ON i.id = sli.itemId
      WHERE sli.shoppingListId = ?
      ORDER BY sli.isChecked ASC, sli.addedAt ASC
    ''', [listId]);

    return maps.map((m) {
      final item = Item.fromMap({
        'id': m['i_id'],
        'name': m['i_name'],
        'category': m['i_category'],
        'unit': m['i_unit'],
        'defaultQuantity': m['i_defaultQuantity'],
        'createdAt': m['i_createdAt'],
        'lastPurchasedAt': m['i_lastPurchasedAt'],
        'averageIntervalDays': m['i_averageIntervalDays'],
        'purchaseCount': m['i_purchaseCount'],
        'icon': m['i_icon'],
      });
      return ShoppingListItem.fromMap(m, item: item);
    }).toList();
  }

  Future<bool> listContainsItem(String listId, String itemId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('shopping_list_items',
        where: 'shoppingListId = ? AND itemId = ?',
        whereArgs: [listId, itemId]);
    return maps.isNotEmpty;
  }

  Future<void> insertListItem(ShoppingListItem sli) async {
    final db = await _dbHelper.database;
    await db.insert('shopping_list_items', sli.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateListItem(ShoppingListItem sli) async {
    final db = await _dbHelper.database;
    await db.update('shopping_list_items', sli.toMap(),
        where: 'id = ?', whereArgs: [sli.id]);
  }

  Future<void> deleteListItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('shopping_list_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countPendingItems(String listId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM shopping_list_items WHERE shoppingListId = ? AND isChecked = 0',
        [listId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
