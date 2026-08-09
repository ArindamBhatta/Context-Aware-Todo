import 'package:sqflite/sqflite.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/add_todo/data/cache/todo_database.dart';

class TodoRepository {
  Future<List<TodoModel>> fetchTasks() async {
    final db = await TodoDatabase.instance.database;
    //get all tasks sorted by start_time ascending
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
  }

  Future<void> updateTask(TodoModel task) async {
    final db = await TodoDatabase.instance.database;
    await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await TodoDatabase.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
