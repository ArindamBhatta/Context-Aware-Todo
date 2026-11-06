import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:todo/features/add_todo/data/cache/todo_database.dart';
import 'package:todo/core/services/api_service.dart';

@pragma('vm:entry-point') // Mandatory for WorkManager!
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 0. Ensure Flutter bindings are initialized in background isolate
      WidgetsFlutterBinding.ensureInitialized();
      // 1. Open the local database
      final db = await TodoDatabase.instance.database;
      // 2. Fetch all tasks where is_synced == 0
      final List<Map<String, dynamic>> unsyncedTasks = await db.query(
        'tasks',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      if (unsyncedTasks.isNotEmpty) {
        // 3. Loop through and push to the Laravel API
        for (var task in unsyncedTasks) {
          final success = await ApiService.instance.pushTask(task);

          // 4. Mark as synced in local DB once successful
          if (success) {
            await db.update(
              'tasks',
              {'is_synced': 1},
              where: 'id = ?',
              whereArgs: [task['id']],
            );
          }
        }
      }
      return Future.value(true); // Tell OS the task succeeded
    } catch (error, stack) {
      debugPrint("Background sync error: $error\n$stack");
      return Future.value(false); // Tell OS it failed, try again later
    }
  });
}
