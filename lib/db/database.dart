import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // ✅ เพิ่มเพื่อจัดการวันที่
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/medicine_mod.dart';
import '../models/period.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        location TEXT,
        note TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        is_all_day INTEGER,
        reminder TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT,
        amount INTEGER,
        times_per_day INTEGER,
        time_slots TEXT,
        time_strings TEXT,
        relation TEXT,
        note TEXT,
        reminder TEXT,
        date TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT,
        volume TEXT,
        mood TEXT,
        symptom TEXT,
        sex_drive TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        location TEXT,
        note TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        is_all_day INTEGER,
        reminder TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT,
        amount INTEGER,
        times_per_day INTEGER,
        time_slots TEXT,
        time_strings TEXT,
        relation TEXT,
        note TEXT,
        reminder TEXT,
        date TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT,
        volume TEXT,
        mood TEXT,
        symptom TEXT,
        sex_drive TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertAppointment(AppointmentModel appointment, int userId) async {
    final db = await database;
    final map = appointment.toMap();
    map['user_id'] = userId;
    return await db.insert('appointments', map);
  }

  Future<List<AppointmentModel>> getAppointmentsByUser(int userId) async {
    final db = await database;
    final result = await db.query('appointments', where: 'user_id = ?', whereArgs: [userId]);
    return result.map((e) => AppointmentModel.fromMap(e)).toList();
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    final db = await database;
    await db.update('appointments', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertMedicine(MedicineModel med, int userId) async {
    final db = await database;
    final map = med.toMap();
    map['user_id'] = userId;
    return await db.insert('medicines', map);
  }

  Future<List<MedicineModel>> getAllMedicines(int userId) async {
    final db = await database;
    final result = await db.query('medicines', where: 'user_id = ?', whereArgs: [userId]);
    return result.map((e) => MedicineModel.fromMap(e)).toList();
  }

  Future<List<MedicineModel>> getTodayMedicines(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final result = await db.query(
      'medicines',
      where: 'date LIKE ? AND user_id = ?',
      whereArgs: ['$today%', userId],
    );
    return result.map((e) => MedicineModel.fromMap(e)).toList();
  }

  Future<void> updateMedicineStatus(int id, String status) async {
    final db = await database;
    await db.update('medicines', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPeriod(PeriodModel period, int userId) async {
    final db = await database;
    final map = period.toMap();
    map['user_id'] = userId;
    return await db.insert('periods', map);
  }

  Future<List<PeriodModel>> getPeriodsByUser(int userId) async {
    final db = await database;
    final result = await db.query('periods', where: 'user_id = ?', whereArgs: [userId]);
    return result.map((e) => PeriodModel.fromMap(e)).toList();
  }

  // ✅ เพิ่มฟังก์ชันนี้ เพื่อดึงข้อมูลตามวัน
  Future<PeriodModel?> getPeriodByDate(int userId, DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final res = await db.query(
      'periods',
      where: 'user_id = ? AND date LIKE ?',
      whereArgs: [userId, '$formattedDate%'],
    );

    if (res.isNotEmpty) {
      return PeriodModel.fromMap(res.first);
    }
    return null;
  }

  Future<void> deleteDatabaseManually() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');
    await deleteDatabase(path);
    print("✅ Database deleted successfully: $path");
  }
}
