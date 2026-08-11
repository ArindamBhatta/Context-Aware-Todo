import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/home/presentation/page/widgets/category_style.dart';
import 'package:todo/features/home/presentation/page/widgets/detail_card.dart';

class QuickWorkDetailsPage extends StatelessWidget {
  final TodoModel task;

  const QuickWorkDetailsPage({super.key, required this.task});

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration.inMinutes == 0) return '0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final CategoryStyle style = getCategoryStyle(task.category);
    final bool isUrgentImportant = task.urgencyLevel == 'Urgent Important';

    final now = DateTime.now();
    final totalDuration = task.endTime.difference(task.startTime);
    final totalMinutes = totalDuration.inMinutes;

    // Time calculations
    final elapsedDuration = now.difference(task.startTime);
    final elapsedMinutes = elapsedDuration.inMinutes.clamp(0, totalMinutes > 0 ? totalMinutes : 1);
    final double coverageRatio = totalMinutes > 0 ? (elapsedMinutes / totalMinutes).clamp(0.0, 1.0) : 0.0;
    final bool isHalfTimeCovered = coverageRatio >= 0.5;

    // Time remaining / Due status
    final remainingDuration = task.endTime.difference(now);
    final bool isPastDue = now.isAfter(task.endTime);

    // Time Saved calculation
    // Planned vs Actual/Remaining:
    // If completed, time saved is difference between endTime and completion/now (if completed early)
    // or planned duration vs actual duration.
    Duration timeSaved = Duration.zero;
    if (!task.isPending) {
      // Completed task: if completed before end time, time saved = end time - now (or remaining duration at completion)
      timeSaved = remainingDuration.isNegative ? Duration.zero : remainingDuration;
    } else {
      // Pending task: estimated time saved if completed right now
      timeSaved = remainingDuration.isNegative ? Duration.zero : remainingDuration;
    }

    final String startTimeFormatted = DateFormat('h:mm a').format(task.startTime);
    final String endTimeFormatted = DateFormat('h:mm a').format(task.endTime);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_rounded,
              color: Theme.of(context).colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Work Details',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: style.backgroundColor,
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: AssetImage(
                            categoryImageMap[task.category] ??
                                'assets/Personal.jpg',
                          ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.55),
                            BlendMode.darken,
                          ),
                        ),
                        border:
                            isUrgentImportant
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 1.5,
                                )
                                : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  style.icon,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  style.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Quick Work',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isUrgentImportant)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Urgent',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            task.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            task.isPending ? 'In Progress' : 'Completed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KEY FOCUS 1: Due Status & Time Remaining Card
                    _buildDueStatusCard(
                      context,
                      task: task,
                      remainingDuration: remainingDuration,
                      isPastDue: isPastDue,
                      endTimeFormatted: endTimeFormatted,
                    ),

                    const SizedBox(height: 16),

                    // KEY FOCUS 2: Time Saved Card
                    _buildTimeSavedCard(
                      context,
                      task: task,
                      totalDuration: totalDuration,
                      timeSaved: timeSaved,
                    ),

                    const SizedBox(height: 16),

                    // KEY FOCUS 3: Time Progress Graph (Shows when 50%+ covered or highlights progress)
                    _buildTimeProgressGraph(
                      context,
                      coverageRatio: coverageRatio,
                      isHalfTimeCovered: isHalfTimeCovered,
                      elapsedDuration: elapsedDuration,
                      totalDuration: totalDuration,
                      startTimeFormatted: startTimeFormatted,
                      endTimeFormatted: endTimeFormatted,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Work Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    DetailCard(
                      icon: Icons.priority_high,
                      label: 'Urgency Level',
                      value: task.urgencyLevel,
                    ),
                    DetailCard(
                      icon: Icons.schedule_rounded,
                      label: 'Time Window',
                      value: '$startTimeFormatted – $endTimeFormatted (${_formatDuration(totalDuration)} allocated)',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<TodoCubit>().deleteTask(task.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await context.read<TodoCubit>().toggleTaskStatus(
                          task.id,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        task.isPending
                            ? Icons.check_rounded
                            : Icons.undo_rounded,
                      ),
                      label: Text(task.isPending ? 'Complete' : 'Reopen'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card showing how much time is due or remaining
  Widget _buildDueStatusCard(
    BuildContext context, {
    required TodoModel task,
    required Duration remainingDuration,
    required bool isPastDue,
    required String endTimeFormatted,
  }) {
    final bool isCompleted = !task.isPending;

    String statusTitle;
    String statusSubtitle;
    Color statusColor;
    IconData statusIcon;

    if (isCompleted) {
      statusTitle = 'Work Completed';
      statusSubtitle = 'Task finished before due time ($endTimeFormatted)';
      statusColor = Colors.green.shade700;
      statusIcon = Icons.task_alt_rounded;
    } else if (isPastDue) {
      statusTitle = 'Overdue by ${_formatDuration(remainingDuration.abs())}';
      statusSubtitle = 'Was due today at $endTimeFormatted';
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusTitle = 'Due in ${_formatDuration(remainingDuration)}';
      statusSubtitle = 'Due today at $endTimeFormatted';
      statusColor = Theme.of(context).colorScheme.primary;
      statusIcon = Icons.timer_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Due Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card showing Time Saved metrics
  Widget _buildTimeSavedCard(
    BuildContext context, {
    required TodoModel task,
    required Duration totalDuration,
    required Duration timeSaved,
  }) {
    final bool isCompleted = !task.isPending;
    final bool hasSavedTime = timeSaved.inMinutes > 0;

    final String timeSavedText = _formatDuration(timeSaved);
    final String totalText = _formatDuration(totalDuration);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.savings_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time Efficiency',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasSavedTime ? Colors.green : Colors.blue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted
                      ? (hasSavedTime ? 'Saved $timeSavedText' : 'Completed On Time')
                      : (hasSavedTime ? '$timeSavedText Potential Savings' : 'Planned $totalText'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasSavedTime ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Planned Time',
                  value: totalText,
                  icon: Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  context,
                  label: isCompleted ? 'Time Saved' : 'Time Saved (If Done Now)',
                  value: hasSavedTime ? timeSavedText : '0m',
                  icon: Icons.bolt_rounded,
                  valueColor: hasSavedTime ? Colors.green.shade700 : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // Time Coverage Graph Widget (Highlight when 50%+ covered)
  Widget _buildTimeProgressGraph(
    BuildContext context, {
    required double coverageRatio,
    required bool isHalfTimeCovered,
    required Duration elapsedDuration,
    required Duration totalDuration,
    required String startTimeFormatted,
    required String endTimeFormatted,
  }) {
    final int percentInt = (coverageRatio * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHalfTimeCovered
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          width: isHalfTimeCovered ? 1.5 : 1.0,
        ),
        boxShadow: isHalfTimeCovered
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 20,
                    color: isHalfTimeCovered
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time Progress Graph',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isHalfTimeCovered ? Colors.orange : Colors.blue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isHalfTimeCovered) ...[
                      const Icon(Icons.flash_on_rounded, size: 13, color: Colors.orange),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      '$percentInt% Time Covered',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isHalfTimeCovered ? Colors.orange.shade800 : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 50% Threshold Banner indicator if 50%+ covered
          if (isHalfTimeCovered) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Half-time milestone reached! 50%+ of allocated time covered.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Graphical Bar Timeline Representation
          Stack(
            children: [
              // Track Background
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              // Filled Progress Bar
              FractionallySizedBox(
                widthFactor: coverageRatio,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        isHalfTimeCovered
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Milestone markers (0%, 50%, 100%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start ($startTimeFormatted)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 13,
                    color: isHalfTimeCovered ? Colors.orange.shade800 : Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '50% Milestone',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHalfTimeCovered ? FontWeight.bold : FontWeight.w500,
                      color: isHalfTimeCovered ? Colors.orange.shade800 : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                'End ($endTimeFormatted)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
