import 'package:flutter/material.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/home/presentation/page/project_work_details_page.dart';
import 'package:todo/features/home/presentation/page/quick_work_details_page.dart';

class DetailsPage extends StatelessWidget {
  final TodoModel task;

  const DetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isSameDay =
        task.startTime.year == task.endTime.year &&
        task.startTime.month == task.endTime.month &&
        task.startTime.day == task.endTime.day;

    if (task.taskType == 'project' || (!isSameDay && task.taskType != 'quick')) {
      return ProjectWorkDetailsPage(task: task);
    } else {
      return QuickWorkDetailsPage(task: task);
    }
  }
}
