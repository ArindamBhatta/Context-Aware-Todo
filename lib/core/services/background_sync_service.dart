import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo/features/add_todo/data/todo_database.dart';
import 'package:todo/core/services/firestore_service.dart';

@pragma('vm:entry-point') // Mandatory for WorkManager!
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 1. Initialize Firebase (since the app might be closed)
      await Firebase.initializeApp();
      // 2. Open the local database
      final db = await TodoDatabase.instance.database;
      // 3. Fetch all tasks where is_synced == 0
      final List<Map<String, dynamic>> unsyncedTasks = await db.query(
        'tasks',
        where: 'is_synced = ?',
        whereArgs: [0],
      );

      if (unsyncedTasks.isNotEmpty) {
        // 4. Loop through and push to Cloud Firestore
        for (var task in unsyncedTasks) {
          final success = await FirestoreService.instance.pushTask(task);

          // 5. Mark as synced in local DB once successful
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
    } catch (error) {
      return Future.value(false); // Tell OS it failed, try again later
    }
  });
}


