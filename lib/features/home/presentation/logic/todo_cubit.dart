import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/features/add_todo/data/todo.dart';
import 'package:todo/features/add_todo/data/todo_repository.dart';

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

  Future<void> _loadTasks() async {
    final tasks = await _repository.fetchTasks();
    if (tasks.isEmpty) {
      emit(TodoEmpty());
      return;
    }

    emit(TodoLoaded(tasks));
  }

  Future<void> addTask(ElementTask task) async {
    await _repository.insertTask(task);
    await _refresh();
  }

  Future<void> updateTask(ElementTask task) async {
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
