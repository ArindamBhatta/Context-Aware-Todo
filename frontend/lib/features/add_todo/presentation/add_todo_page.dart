import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();

  String taskGroup = categoryImageMap.keys.first;
  String projectName = '';
  String description = '';

  int selectedTabIndex = 0; // 0: Quick Work, 1: Project Work

  late DateTime startDate;
  late DateTime endDate;

  late TimeOfDay startTime;
  late TimeOfDay endTime;

  TodoUrgencyLevel urgencyLevel = TodoUrgencyLevel.urgentImportant;

  @override
  void initState() {
    super.initState();
    final today = _today();
    startDate = today;
    endDate = today;

    final now = TimeOfDay.now();
    startTime = now;
    endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _pickDate(bool isStartDate) async {
    final initialDate = isStartDate ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate.isBefore(startDate)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final initialTime = isStartTime ? startTime : endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _showCategoryPicker() async {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Task Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: categoryImageMap.length,
                    itemBuilder: (context, index) {
                      final category = categoryImageMap.keys.elementAt(index);
                      final imagePath = categoryImageMap[category]!;
                      final isSelected = category == taskGroup;

                      return InkWell(
                        onTap: () => Navigator.pop(context, category),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => taskGroup = selected);
    }
  }

  Future<void> _showUrgencyPicker() async {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<TodoUrgencyLevel>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Urgency Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...TodoUrgencyLevel.values.map((level) {
                  final isSelected = level == urgencyLevel;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getTodoIconData(level.value),
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      level.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                            )
                            : null,
                    onTap: () => Navigator.pop(context, level),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => urgencyLevel = selected);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = projectName.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedTabIndex == 0
                ? 'Please enter a task name'
                : 'Please enter a project name',
          ),
        ),
      );
      return;
    }

    final DateTime taskStart;
    final DateTime taskEnd;

    if (selectedTabIndex == 0) {
      // Quick Work: uses today's date with selected time
      final today = _today();
      taskStart = DateTime(
        today.year,
        today.month,
        today.day,
        startTime.hour,
        startTime.minute,
      );
      taskEnd = DateTime(
        today.year,
        today.month,
        today.day,
        endTime.hour,
        endTime.minute,
      );
    } else {
      // Project Work: uses selected start and end dates
      taskStart = startDate;
      taskEnd = endDate;
    }

    final task = TodoModel(
      id: uuid.v4(),
      name: trimmedName,
      description: description,
      startTime: taskStart,
      endTime: taskEnd,
      category: taskGroup,
      urgencyLevel: urgencyLevel.value,
      isPending: true,
      taskType: selectedTabIndex == 0 ? 'quick' : 'project',
    );

    context.read<TodoCubit>().addTask(task);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          selectedTabIndex == 0 ? 'Add Quick Task' : 'Add Project',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: colorScheme.onSurface,
                  size: 28,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Tab selector: Quick Work vs Project Work
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 0;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  selectedTabIndex == 0
                                      ? colorScheme.surface
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                                  selectedTabIndex == 0
                                      ? [
                                        BoxShadow(
                                          color: colorScheme.shadow.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 18,
                                  color:
                                      selectedTabIndex == 0
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Quick Work',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        selectedTabIndex == 0
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTabIndex = 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  selectedTabIndex == 1
                                      ? colorScheme.surface
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                                  selectedTabIndex == 1
                                      ? [
                                        BoxShadow(
                                          color: colorScheme.shadow.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_special_rounded,
                                  size: 18,
                                  color:
                                      selectedTabIndex == 1
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Project Work',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color:
                                        selectedTabIndex == 1
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Task Group Card (Same for both)
                GestureDetector(
                  onTap: _showCategoryPicker,
                  child: _buildCard(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            categoryImageMap[taskGroup]!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Task Group',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                taskGroup,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.onSurface,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),

                // Title Card
                _buildCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedTabIndex == 0 ? 'Task Name' : 'Project Name',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextFormField(
                        key: ValueKey('name_$selectedTabIndex'),
                        initialValue: projectName,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              selectedTabIndex == 0
                                  ? 'e.g., Take medicine, Clean room'
                                  : 'Enter project name',
                          isDense: true,
                          contentPadding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return selectedTabIndex == 0
                                ? 'Task name is required'
                                : 'Project name is required';
                          }
                          return null;
                        },
                        onChanged: (val) => projectName = val,
                      ),
                    ],
                  ),
                ),

                // Description Card
                _buildCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextFormField(
                        key: ValueKey('desc_$selectedTabIndex'),
                        initialValue: description,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              selectedTabIndex == 0
                                  ? 'Enter task description (optional)'
                                  : 'Enter project description (optional)',
                          isDense: true,
                          contentPadding: const EdgeInsets.only(
                            top: 12,
                            bottom: 8,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => description = val,
                      ),
                    ],
                  ),
                ),

                // Time Pickers for Quick Work OR Date Pickers for Project Work
                if (selectedTabIndex == 0) ...[
                  GestureDetector(
                    onTap: () => _pickTime(true),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  startTime.format(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurface,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickTime(false),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  endTime.format(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurface,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => _pickDate(true),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'dd MMMM, yyyy',
                                  ).format(startDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurface,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(false),
                    child: _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMMM, yyyy').format(endDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: colorScheme.onSurface,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Urgency Level (Same for both)
                GestureDetector(
                  onTap: _showUrgencyPicker,
                  child: _buildCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getTodoIconData(urgencyLevel.value),
                            color: colorScheme.tertiary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Urgency Level',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                urgencyLevel.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.onSurface,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _saveTask,
                    child: Text(
                      selectedTabIndex == 0
                          ? 'Add Quick Task'
                          : 'Add Project',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
