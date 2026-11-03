part of 'todo_cubit.dart';

sealed class TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> tasks;
  TodoLoaded(this.tasks);
}

class TodoEmpty extends TodoState {}

class TaskError extends TodoState {
  final String? message;
  TaskError(this.message);
}
