import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TodoDatabase {
  TodoDatabase._(); //private constructor

  static final TodoDatabase instance = TodoDatabase._(); //singleton

  static Database? _database; //caching the db object

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasesPath =
        await getDatabasesPath(); //data/data/<package_name>/databases

    final path = join(
      databasesPath,
      'todo_cache.db',
    ); //joins paths to form db path

    return openDatabase(
      path,
      version: 4,
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
            end_time TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0 
          )
        ''');
        await db.execute('''
          CREATE TABLE locations(
            category TEXT PRIMARY KEY,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
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
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS locations(
              category TEXT PRIMARY KEY,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL
            )
          ''');
        }
      },
    );
  }
}
