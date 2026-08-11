import 'package:sqflite/sqflite.dart';
import 'package:todo/core/services/firestore_service.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/add_todo/data/cache/todo_database.dart';

class TodoRepository {
  Future<List<TodoModel>> fetchTasks() async {
    //get db instance using singleton
    final Database db = await TodoDatabase.instance.database;

    //get all tasks from db sorted by start_time ascending
    final rows = await db.query('tasks', orderBy: 'start_time ASC');

    //convert rows to ElementTask list
    return rows.map(TodoModel.fromJson).toList();
  }

  Future<void> insertTask(TodoModel task) async {
    final db = await TodoDatabase.instance.database;
    await db.insert(
      'tasks',
      task.toJson(),
      //if task already exists, replace it
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _tryPushToFirestore(task.toJson());
  }

  Future<void> updateTask(TodoModel task) async {
    final db = await TodoDatabase.instance.database;
    await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _tryPushToFirestore(task.toJson());
  }

  Future<void> _tryPushToFirestore(Map<String, dynamic> taskMap) async {
    final success = await FirestoreService.instance.pushTask(taskMap);
    if (success) {
      final db = await TodoDatabase.instance.database;
      await db.update(
        'tasks',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [taskMap['id']],
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final db = await TodoDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
