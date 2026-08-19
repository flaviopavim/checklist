import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lista_compras.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        unit TEXT,
        defaultQuantity REAL NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastPurchasedAt TEXT,
        averageIntervalDays REAL,
        purchaseCount INTEGER NOT NULL DEFAULT 0,
        icon TEXT NOT NULL DEFAULT '🛒'
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_lists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_list_items (
        id TEXT PRIMARY KEY,
        shoppingListId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        isChecked INTEGER NOT NULL DEFAULT 0,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (shoppingListId) REFERENCES shopping_lists (id) ON DELETE CASCADE,
        FOREIGN KEY (itemId) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_records (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        quantity REAL NOT NULL,
        shoppingListId TEXT,
        FOREIGN KEY (itemId) REFERENCES items (id) ON DELETE CASCADE,
        FOREIGN KEY (shoppingListId) REFERENCES shopping_lists (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_sli_list ON shopping_list_items (shoppingListId)');
    await db.execute(
        'CREATE INDEX idx_sli_item ON shopping_list_items (itemId)');
    await db.execute('CREATE INDEX idx_pr_item ON purchase_records (itemId)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
