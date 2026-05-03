import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_drive_service.dart';

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

  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'borrow_manager.db');
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasePath();
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        clientName TEXT,
        amount REAL,
        reminderDateTime TEXT,
        note TEXT,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientId INTEGER,
          clientName TEXT,
          amount REAL,
          reminderDateTime TEXT,
          note TEXT,
          isCompleted INTEGER DEFAULT 0
        )
      ''');
    }
  }

  // Helper to trigger backup
  Future<void> _triggerAutoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('useGoogleBackup') ?? false) {
      // Trigger backup in background
      GoogleDriveService.backupDatabase();
    }
  }

  // --- Client Operations ---
  Future<int> insertClient(Map<String, dynamic> row) async {
    Database db = await database;
    int id = await db.insert('clients', row);
    _triggerAutoBackup();
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllClients() async {
    Database db = await database;
    return await db.query('clients');
  }

  // --- Transaction Operations ---
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    Database db = await database;
    int id = await db.insert('transactions', row);
    _triggerAutoBackup();
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllTransactions() async {
    Database db = await database;
    return await db.query('transactions');
  }

  // --- Reminder Operations ---
  Future<int> insertReminder(Map<String, dynamic> row) async {
    Database db = await database;
    int id = await db.insert('reminders', row);
    _triggerAutoBackup();
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllReminders() async {
    Database db = await database;
    return await db.query('reminders', where: 'isCompleted = 0', orderBy: 'reminderDateTime ASC');
  }

  Future<int> updateReminderStatus(int id, int isCompleted) async {
    Database db = await database;
    int result = await db.update('reminders', {'isCompleted': isCompleted}, where: 'id = ?', whereArgs: [id]);
    _triggerAutoBackup();
    return result;
  }

  Future<int> deleteReminder(int id) async {
    Database db = await database;
    int result = await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    _triggerAutoBackup();
    return result;
  }
}
