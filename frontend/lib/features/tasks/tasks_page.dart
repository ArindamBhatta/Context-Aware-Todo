import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedStatusFilter = 'All'; // 'All', 'To do', 'In Progress', 'Done'

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceBright,
        elevation: 0,
        title: Text(
          "Today's Tasks",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 1. TOP HORIZONTAL CALENDAR STRIP
            _buildDateStrip(),

            const SizedBox(height: 20),

            // 2. HORIZONTAL FILTER CHIPS (All, To do, In Progress, Done)
            _buildFilterChips(),

            const SizedBox(height: 16),

            // 3. TASK LIST
            Expanded(
              child: BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }
                  if (state is TaskError) {
                    debugPrint(state.message);
                    return Center(
                      child: Text(
                        'Failed to load tasks',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    );
                  }
                  if (state is TodoEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_todo.png',
                            height: 1000,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final tasks = (state as TodoLoaded).tasks;

                  // Filter tasks based on selected date & status filter
                  final filteredTasks =
                      tasks.where((task) {
                        final isSameDate = isSameDay(
                          task.startTime,
                          _selectedDate,
                        );

                        bool matchesStatus = true;
                        if (_selectedStatusFilter == 'To do') {
                          matchesStatus = task.isPending;
                        } else if (_selectedStatusFilter == 'Done') {
                          matchesStatus = !task.isPending;
                        }

                        return isSameDate && matchesStatus;
                      }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Image.asset(
                        'assets/images/no_todo.png',
                        height: 1000,
                        fit: BoxFit.contain,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDateStrip() {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final dates = List.generate(
      7,
      (i) => today.subtract(const Duration(days: 2)).add(Duration(days: i)),
    );

    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.8)
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = ['All', 'To do', 'In Progress', 'Done'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = _selectedStatusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color:
                            isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatusFilter = filter;
                      });
                    }
                  },
                  backgroundColor: colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  selectedColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  showCheckmark: false,
                  side: BorderSide.none,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(TodoModel task) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = !task.isPending;
    final statusText = isDone ? 'Done' : 'To-do';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category subtitle
                Text(
                  task.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // Task Name
                Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isDone
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Start Time & Status Tag Row
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(task.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    // Status Badge (Done / To-do)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDone
                                ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                )
                                : colorScheme.secondaryContainer.withValues(
                                  alpha: 0.4,
                                ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              isDone
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Action/Category Icon on Top-Right
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
