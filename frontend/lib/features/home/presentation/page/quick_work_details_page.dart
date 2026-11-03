import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/home/presentation/page/widgets/category_style.dart';

class QuickWorkDetailsPage extends StatefulWidget {
  final TodoModel task;

  const QuickWorkDetailsPage({super.key, required this.task});

  @override
  State<QuickWorkDetailsPage> createState() => _QuickWorkDetailsPageState();
}

class _QuickWorkDetailsPageState extends State<QuickWorkDetailsPage> {
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    // Real-time 1-second ticker to smoothly update time elapsed, countdown, and progress indicator
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration.inSeconds == 0) return '0s';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final CategoryStyle style = getCategoryStyle(task.category);
    final bool isUrgentImportant = task.urgencyLevel == 'Urgent Important';

    final now = DateTime.now();
    final totalDuration = task.endTime.difference(task.startTime);
    final totalSeconds = totalDuration.inSeconds;

    // Time calculations with second precision for continuous smooth progress
    final elapsedDuration = now.difference(task.startTime);
    final elapsedSeconds = elapsedDuration.inSeconds.clamp(
      0,
      totalSeconds > 0 ? totalSeconds : 1,
    );
    final double coverageRatio =
        totalSeconds > 0
            ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
            : 0.0;
    final bool isHalfTimeCovered = coverageRatio >= 0.5;

    // Time remaining / Due status
    final remainingDuration = task.endTime.difference(now);
    final bool isPastDue = now.isAfter(task.endTime);

    // Time Saved calculation
    Duration timeSaved = Duration.zero;
    if (!task.isPending) {
      timeSaved =
          remainingDuration.isNegative ? Duration.zero : remainingDuration;
    } else {
      timeSaved =
          remainingDuration.isNegative ? Duration.zero : remainingDuration;
    }

    final String startTimeFormatted = DateFormat(
      'h:mm a',
    ).format(task.startTime);
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
                                  borderRadius: BorderRadius.circular(12),
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

                    // State-driven Hero Card (Time Saved vs Time Left)
                    if (!task.isPending)
                      _buildTimeSavedHeroCard(
                        context,
                        task: task,
                        totalDuration: totalDuration,
                        timeSaved: timeSaved,
                        endTimeFormatted: endTimeFormatted,
                      )
                    else
                      _buildTimeLeftHeroCard(
                        context,
                        task: task,
                        remainingDuration: remainingDuration,
                        totalDuration: totalDuration,
                        isPastDue: isPastDue,
                        startTimeFormatted: startTimeFormatted,
                        endTimeFormatted: endTimeFormatted,
                      ),

                    const SizedBox(height: 16),

                    // Time Progress Graph with Green, Yellow, Red Indicator
                    _buildTimeProgressGraph(
                      context,
                      coverageRatio: !task.isPending ? 1.0 : coverageRatio,
                      isHalfTimeCovered:
                          !task.isPending ? true : isHalfTimeCovered,
                      elapsedDuration: elapsedDuration,
                      totalDuration: totalDuration,
                      startTimeFormatted: startTimeFormatted,
                      endTimeFormatted: endTimeFormatted,
                      isCompleted: !task.isPending,
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

  // Hero Card when task is INCOMPLETE: Highlights TIME LEFT in real-time
  Widget _buildTimeLeftHeroCard(
    BuildContext context, {
    required TodoModel task,
    required Duration remainingDuration,
    required Duration totalDuration,
    required bool isPastDue,
    required String startTimeFormatted,
    required String endTimeFormatted,
  }) {
    final String timeLeftText = _formatDuration(remainingDuration);
    final String totalText = _formatDuration(totalDuration);

    final String statusTitle;
    final String statusSubtitle;
    final Color statusColor;
    final IconData statusIcon;

    if (isPastDue) {
      statusTitle = 'Overdue by ${_formatDuration(remainingDuration.abs())}';
      statusSubtitle =
          'Was due today at $endTimeFormatted ($startTimeFormatted – $endTimeFormatted)';
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusTitle = '$timeLeftText Left';
      statusSubtitle = 'Task window: $startTimeFormatted – $endTimeFormatted';
      statusColor = Theme.of(context).colorScheme.primary;
      statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Time Left to Complete',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPastDue ? 'Overdue' : 'Live Ticker',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: statusColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusSubtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Planned Window',
                  value: totalText,
                  icon: Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  context,
                  label: isPastDue ? 'Overdue Duration' : 'Time Left',
                  value:
                      isPastDue
                          ? _formatDuration(remainingDuration.abs())
                          : timeLeftText,
                  icon: Icons.timer_outlined,
                  valueColor: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hero Card when task is COMPLETE: Highlights TIME SAVED
  Widget _buildTimeSavedHeroCard(
    BuildContext context, {
    required TodoModel task,
    required Duration totalDuration,
    required Duration timeSaved,
    required String endTimeFormatted,
  }) {
    final bool hasSavedTime = timeSaved.inMinutes > 0;
    final String timeSavedText = _formatDuration(timeSaved);
    final String totalText = _formatDuration(totalDuration);

    final Color cardColor = Colors.green.shade700;
    final Color cardBg = Colors.green.shade50;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.08),
            blurRadius: 12,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasSavedTime
                          ? Icons.bolt_rounded
                          : Icons.check_circle_rounded,
                      color: cardColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Time Saved & Efficiency',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cardColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasSavedTime ? '🎉 Early Finish' : '✅ Completed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hasSavedTime ? '⚡ $timeSavedText Saved!' : 'Completed On Schedule',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: cardColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSavedTime
                ? 'Great job! You finished ahead of your $endTimeFormatted deadline.'
                : 'Task completed successfully within your scheduled window ($endTimeFormatted).',
            style: TextStyle(fontSize: 12, color: Colors.green.shade900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Planned Duration',
                  value: totalText,
                  icon: Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Total Time Saved',
                  value: hasSavedTime ? timeSavedText : '0m',
                  icon: Icons.savings_rounded,
                  valueColor: cardColor,
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
              Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

  // Time Coverage Graph Widget with Green, Yellow, Red Zones and Moving Position Pin
  Widget _buildTimeProgressGraph(
    BuildContext context, {
    required double coverageRatio,
    required bool isHalfTimeCovered,
    required Duration elapsedDuration,
    required Duration totalDuration,
    required String startTimeFormatted,
    required String endTimeFormatted,
    required bool isCompleted,
  }) {
    final int percentInt = (coverageRatio * 100).toInt();

    // Zone-based color determination:
    // Green (0% - 50%): Safe / On Track
    // Yellow/Amber (50% - 85%): Half-time / Caution
    // Red (85% - 100%+): Final Push / Overdue
    final Color currentZoneColor = isCompleted
        ? Colors.green.shade700
        : (coverageRatio < 0.5
            ? const Color(0xFF2E7D32) // Green
            : (coverageRatio < 0.85
                ? const Color(0xFFF57F17) // Amber/Yellow
                : const Color(0xFFD32F2F))); // Red

    final String zoneLabel = isCompleted
        ? '100% Completed'
        : (coverageRatio < 0.5
            ? '$percentInt% • On Track'
            : (coverageRatio < 0.85
                ? '$percentInt% • Half-Time'
                : '$percentInt% • Final Push'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: currentZoneColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: currentZoneColor.withValues(alpha: 0.08),
            blurRadius: 12,
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
                    Icons.auto_graph_rounded,
                    size: 20,
                    color: currentZoneColor,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: currentZoneColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : (coverageRatio < 0.5
                              ? Icons.shield_outlined
                              : (coverageRatio < 0.85
                                  ? Icons.flash_on_rounded
                                  : Icons.warning_amber_rounded)),
                      size: 13,
                      color: currentZoneColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      zoneLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: currentZoneColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Real-time Tri-Color Track (Green -> Yellow -> Red) with Moving Pointer Pin
          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              const double pinDiameter = 22.0;
              final double maxTranslate = (totalWidth - pinDiameter).clamp(0.0, totalWidth);
              final double currentPosition = (coverageRatio * maxTranslate).clamp(0.0, maxTranslate);

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Base Track with Green, Yellow, Red Gradient Background
                  Container(
                    height: 16,
                    width: totalWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF81C784), // Soft Green (Start)
                          Color(0xFFFFD54F), // Soft Yellow (Half-time)
                          Color(0xFFE57373), // Soft Red (End)
                        ],
                        stops: [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // Active Filled Track Overlay (Vibrant Gradient up to current ratio)
                  FractionallySizedBox(
                    widthFactor: coverageRatio.clamp(0.02, 1.0),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                              : [
                                  const Color(0xFF4CAF50), // Vibrant Green
                                  const Color(0xFFFFB300), // Vibrant Yellow/Amber
                                  const Color(0xFFD32F2F), // Vibrant Red
                                ],
                          stops: const [0.0, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Moving Pointer Pin Indicator (glides continuously in real-time)
                  Positioned(
                    left: currentPosition,
                    child: Container(
                      width: pinDiameter,
                      height: pinDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: currentZoneColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentZoneColor.withValues(alpha: 0.45),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentZoneColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Zone Color Legend (Green, Yellow, Red) & Timestamps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'On Track ($startTimeFormatted)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFB300),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Half-Time',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline ($endTimeFormatted)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
