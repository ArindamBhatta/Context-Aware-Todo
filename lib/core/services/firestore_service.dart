import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pushes a local task map to the 'tasks' collection in Cloud Firestore.
  Future<bool> pushTask(Map<String, dynamic> taskMap) async {
    try {
      final String taskId = taskMap['id'].toString();
      
      // Make a clean copy for Firestore (removing local-only sync fields if desired)
      final dataToSave = Map<String, dynamic>.from(taskMap);
      dataToSave.remove('is_synced'); 

      await _firestore
          .collection('tasks')
          .doc(taskId)
          .set(dataToSave, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }
}
