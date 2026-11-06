import 'dart:convert';

import 'package:http/http.dart' as http;

/// Talks to the Laravel backend (`backend/routes/api.php` -> /api/todos).
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
  /// Override at build time:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Pushes a local task map to Laravel. Updates the todo if it exists
  /// (PUT /todos/{id}), otherwise creates it (POST /todos).
  Future<bool> pushTask(Map<String, dynamic> taskMap) async {
    try {
      final String taskId = taskMap['id'].toString();

      // Drop local-only sync fields before sending.
      final Map<String, dynamic> body = Map<String, dynamic>.from(taskMap)
        ..remove('is_synced');
      final String payload = jsonEncode(body);

      final http.Response updateResponse = await http.put(
        Uri.parse('$baseUrl/todos/$taskId'),
        headers: _headers,
        body: payload,
      );
      if (updateResponse.statusCode == 200) {
        return true;
      }

      if (updateResponse.statusCode == 404) {
        final http.Response createResponse = await http.post(
          Uri.parse('$baseUrl/todos'),
          headers: _headers,
          body: payload,
        );
        return createResponse.statusCode == 201;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
