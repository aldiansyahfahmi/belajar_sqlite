import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<void> createTable(Database db) async {
    await db.execute('''CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT,
    email TEXT,
    image TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )''');
  }

  static Future<Database> db() async {
    return openDatabase(
      'mydb',
      version: 1,
      onCreate: (db, version) async {
        await createTable(db);
      },
    );
  }

  static Future<void> create(String name, String email, String image) async {
    final db = await DatabaseHelper.db();
    final data = {'name': name, 'email': email, 'image': image};
    await db.insert('users', data);
  }

  static Future<List<Map<String, dynamic>>> get() async {
    final db = await DatabaseHelper.db();
    return db.query('users', orderBy: 'id');
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseHelper.db();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> update(int id, String name, String email) async {
    final db = await DatabaseHelper.db();
    final data = {'name': name, 'email': email};
    await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }
}
