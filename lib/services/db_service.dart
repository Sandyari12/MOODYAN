import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/mood_journal.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moodtracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE moods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mood TEXT,
            emoji TEXT,
            note TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<User?> validateLogin(String email, String password) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> insertMood(MoodJournal mood) async {
    final db = await database;
    return await db.insert('moods', mood.toMap());
  }

  static Future<List<MoodJournal>> getAllMoods() async {
    final db = await database;
    final result = await db.query('moods', orderBy: 'date DESC');
    print('All moods in DB:');
    for (var e in result) {
      print('date: \'${e['date']}\', mood: \'${e['mood']}\', note: \'${e['note']}\'');
    }
    return result.map((e) => MoodJournal.fromMap(e)).toList();
  }

  static Future<int> updateMood(MoodJournal mood) async {
    final db = await database;
    if (mood.id == null) return 0;
    final result = await db.update('moods', mood.toMap(), where: 'id = ?', whereArgs: [mood.id]);
    print("UpdateMood: updated $result row(s) for id: '${mood.id}'");
    return result;
  }

  static Future<int> deleteMood(String date) async {
    final db = await database;
    return await db.delete('moods', where: 'date = ?', whereArgs: [date]);
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'email = ?', whereArgs: [user.email]);
  }
} 