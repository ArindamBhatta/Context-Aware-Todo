import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/add_todo/data/repo/todo_repository.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _repository;

  TodoCubit(this._repository) : super(TodoLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadTasks();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _refresh() async {
    await _loadTasks();
  }

  String? _currentLocationCategory;

  void setLocationCategory(String? category) {
    _currentLocationCategory = category;
    _refresh();
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.fetchTasks();
    if (tasks.isEmpty) {
      emit(TodoEmpty());
      return;
    }

    List<TodoModel> filteredTasks = tasks;
    if (_currentLocationCategory != null) {
      filteredTasks = tasks.where((t) => t.category == _currentLocationCategory).toList();
    }

    emit(TodoLoaded(filteredTasks));
  }

  Future<void> addTask(TodoModel task) async {
    await _repository.insertTask(task);
    await _refresh();
  }

  Future<void> updateTask(TodoModel task) async {
    await _repository.updateTask(task);
    await _refresh();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await _refresh();
  }

  Future<void> toggleTaskStatus(String id) async {
    final currentState = state;
    final tasks =
        currentState is TodoLoaded
            ? currentState.tasks
            : await _repository.fetchTasks();

    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final toggled = tasks[taskIndex].copyWith(
      isPending: !tasks[taskIndex].isPending,
    );
    await _repository.updateTask(toggled);
    await _refresh();
  }
}
