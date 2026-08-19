import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/purchase_record.dart';

class PurchaseRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<void> insertRecord(PurchaseRecord record) async {
    final db = await _dbHelper.database;
    await db.insert('purchase_records', record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PurchaseRecord>> getRecordsForItem(String itemId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('purchase_records',
        where: 'itemId = ?',
        whereArgs: [itemId],
        orderBy: 'purchaseDate ASC');
    return maps.map((m) => PurchaseRecord.fromMap(m)).toList();
  }
}
