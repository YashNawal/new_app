import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'borrow_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance REAL,
        isOwesMe INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientName TEXT,
        amount REAL,
        isLent INTEGER,
        date TEXT,
        note TEXT
      )
    ''');
  }

  // --- Client Operations ---
  Future<int> insertClient(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('clients', row);
  }

  Future<List<Map<String, dynamic>>> queryAllClients() async {
    Database db = await database;
    return await db.query('clients');
  }

  // --- Transaction Operations ---
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> queryAllTransactions() async {
    Database db = await database;
    return await db.query('transactions');
  }
}
