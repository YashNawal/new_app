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
        isOwesMe INTEGER,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        clientName TEXT,
        principal REAL,
        interest_rate REAL,
        tenure_months INTEGER,
        emi_amount REAL,
        remaining_balance REAL,
        isLent INTEGER,
        date TEXT,
        note TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        transaction_id TEXT,
        amount REAL,
        date TEXT,
        type TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        clientName TEXT,
        amount REAL,
        reminderDateTime TEXT,
        note TEXT,
        isCompleted INTEGER
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

  Future<int> updateTransaction(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(
      'transactions',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllTransactions() async {
    Database db = await database;
    return await db.query('transactions');
  }

  Future<Map<String, dynamic>?> queryTransactionById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // --- Payment Operations ---
  Future<int> insertPayment(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('payments', row);
  }

  Future<List<Map<String, dynamic>>> queryPaymentsByTransaction(String transactionId) async {
    Database db = await database;
    return await db.query(
      'payments',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'date DESC',
    );
  }

  // --- Reminder Operations ---
  Future<int> insertReminder(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('reminders', row);
  }

  Future<List<Map<String, dynamic>>> queryAllReminders() async {
    Database db = await database;
    return await db.query('reminders');
  }
}
