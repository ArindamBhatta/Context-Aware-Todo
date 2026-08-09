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

  // Primary Theme Colors based on design
  static const Color primaryPurple = Color(0xFF6C4DFF);
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color chipUnselectedBg = Color(0xFFF0EFFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Today's Tasks",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
                    return const Center(
                      child: CircularProgressIndicator(color: primaryPurple),
                    );
                  }
                  if (state is TaskError) {
                    return Center(
                      child: Text('Failed to load tasks: ${state.message}'),
                    );
                  }
                  if (state is TodoEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_todo.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No tasks found',
                            style: TextStyle(
                              color: Color(0xFF64748B),
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
                        // Add your custom logic for 'In Progress' if required in your backend

                        return isSameDate && matchesStatus;
                      }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_todo.png',
                            height: 400,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No tasks found for this day',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
    // Generates dates centered around selected date (e.g., 7-day view window)
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
                color: isSelected ? primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
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
                        color: isSelected ? Colors.white : primaryPurple,
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
                  backgroundColor: chipUnselectedBg,
                  selectedColor: primaryPurple,
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
    final isDone = !task.isPending;
    final statusText = isDone ? 'Done' : 'To-do';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
                    color: isDone ? Colors.grey : Colors.black87,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Start Time & Status Tag Row
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: primaryPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(task.startTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: primaryPurple,
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
                                ? const Color(0xFFE8E5FF)
                                : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              isDone ? primaryPurple : const Color(0xFF0284C7),
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
              color: const Color(0xFFFFEBF0), // Soft background container
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: Colors.pinkAccent,
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
