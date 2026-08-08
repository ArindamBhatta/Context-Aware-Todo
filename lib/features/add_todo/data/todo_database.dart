import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase {
  TodoDatabase._();

  static final TodoDatabase instance = TodoDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_cache.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            is_pending INTEGER NOT NULL,
            urgency_level TEXT NOT NULL,
            category TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL DEFAULT ''
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE tasks ADD COLUMN end_time TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
  }
}
