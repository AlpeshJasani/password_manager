import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'password_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            note TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertPassword(Password password) async {
    final db = await database;
    return await db.insert('passwords', password.toMap());
  }

  Future<List<Password>> getPasswords() async {
    final db = await database;
    final result = await db.query('passwords');
    return result.map((map) => Password.fromMap(map)).toList();
  }

  Future<int> updatePassword(Password password) async {
    final db = await database;
    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
