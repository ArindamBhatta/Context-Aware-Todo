import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

//Urgency Levels
enum TodoUrgencyLevel {
  urgentImportant("Urgent Important"),
  notUrgentImportant("Not Urgent Important"),
  notImportantUrgent("Not Important Urgent"),
  notImportantNotUrgent("Not Important Not Urgent");

  final String value;
  const TodoUrgencyLevel(this.value);
}

//Urgency Level Icons
IconData getTodoIconData(String urgencyLevel) {
  switch (urgencyLevel) {
    case 'Urgent Important':
      return Icons.priority_high;
    case 'Not Urgent Important':
      return Icons.check_circle_outline;
    case 'Not Important Urgent':
      return Icons.access_alarm;
    case 'Not Important Not Urgent':
      return Icons.check_circle;
    default:
      return Icons.error;
  }
}

// Different Categories of Todos
enum Category {
  office("Office"),
  health("Health"),
  finance("Finance"),
  home("Home"),
  personal("Personal"),
  career("Career"),
  self("Self"),
  leisure("Leisure"),
  fun("Fun");

  final String value;
  const Category(this.value);
}

final Map<String, String> categoryImageMap = {
  'Office': 'assets/images/categories/Office.jpg',
  'Health': 'assets/images/categories/Health.jpg',
  'Finance': 'assets/images/categories/finance.jpg',
  'Home': 'assets/images/categories/Home.jpg',
  'Personal': 'assets/images/categories/Personal.jpg',
  'Career': 'assets/images/categories/Career.jpg',
  'Self': 'assets/images/categories/Self_Development.jpg',
  'Leisure': 'assets/images/categories/Leisure.jpg',
  'Fun': 'assets/images/categories/Fun.jpg',
};

class TodoModel {
  final String id;
  final String category;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String urgencyLevel;
  final bool isPending;

  TodoModel({
    String? id,
    required this.category,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.urgencyLevel,
    required this.isPending,
  }) : id = id ?? uuid.v4();

  TodoModel copyWith({
    String? id,
    String? category,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? urgencyLevel,
    bool? isPending,
  }) {
    return TodoModel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isPending: isPending ?? this.isPending,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'urgency_level': urgencyLevel,
      'is_pending': isPending ? 1 : 0,
      'is_synced': 0, //! To be Synced
    };
  }

  //
  static String _readString(
    Map<String, Object?> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  static DateTime _readDateTime(
    Map<String, Object?> json,
    List<String> keys, {
    required DateTime fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
    }

    return fallback;
  }

  //SQLite stores booleans as 1/0(num).
  static bool _readBool(
    Map<String, Object?> json,
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value.toInt() == 1;
      }

      final text = value.toString().toLowerCase();
      if (text == '1' || text == 'true') {
        return true;
      }
      if (text == '0' || text == 'false') {
        return false;
      }
    }

    return fallback;
  }

  factory TodoModel.fromJson(Map<String, Object?> json) {
    final startTime = _readDateTime(json, [
      'start_time',
    ], fallback: DateTime.now());

    final endTime = _readDateTime(json, ['end_time'], fallback: startTime);

    return TodoModel(
      id: _readString(json, ['id'], fallback: uuid.v4()),

      category: _readString(json, [
        'category',
      ], fallback: Category.personal.value),

      name: _readString(json, ['name'], fallback: 'Untitled task'),

      description: _readString(json, ['description']),

      startTime: startTime,
      endTime: endTime,

      urgencyLevel: _readString(json, [
        'urgency_level',
      ], fallback: TodoUrgencyLevel.notUrgentImportant.value),
      isPending: _readBool(json, ['is_pending'], fallback: true),
    );
  }
}
