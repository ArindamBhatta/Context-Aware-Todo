import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/core/theme/app_theme.dart';
import 'package:todo/features/add_todo/data/model/todo.dart';
import 'package:todo/features/auth/presentation/logic/auth_cubit.dart';
import 'package:todo/features/auth/presentation/logic/auth_state.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Ensure auth state is refreshed when opening profile page
    context.read<AuthCubit>().syncAuthState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profile & Activity',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;

          return BlocBuilder<TodoCubit, TodoState>(
            builder: (context, todoState) {
              final tasks = todoState is TodoLoaded ? todoState.tasks : <TodoModel>[];

              final completedTasks = tasks.where((t) => !t.isPending).toList();
              final quickWorkCompleted = completedTasks.where((t) => t.taskType == 'quick').length;
              final projectWorkCompleted = completedTasks.where((t) => t.taskType == 'project').length;
              final streakDays = _calculateCurrentStreak(completedTasks);

              return SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header Card
                    _buildUserHeaderCard(context, user),
                    SizedBox(height: AppTheme.spacingM),

                    // Quick Stats Row
                    _buildStatsRow(
                      context,
                      totalCompleted: completedTasks.length,
                      quickCompleted: quickWorkCompleted,
                      projectCompleted: projectWorkCompleted,
                      streakDays: streakDays,
                    ),
                    SizedBox(height: AppTheme.spacingL),

                    // GitHub-Style Activity Contribution Grid Card
                    _buildGithubActivityCard(context, completedTasks),
                    SizedBox(height: AppTheme.spacingL),

                    // Account Settings & Sign Out
                    _buildAccountActionsCard(context),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserHeaderCard(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user?.photoUrl == null || user!.photoUrl.isEmpty
                  ? Icon(Icons.person, size: 36, color: colorScheme.primary)
                  : null,
            ),
          ),
          SizedBox(width: AppTheme.spacingM),

          // User info details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Signed in User',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'No email available',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.g_mobiledata_rounded, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Google Verified Account',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required int totalCompleted,
    required int quickCompleted,
    required int projectCompleted,
    required int streakDays,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatItemCard(
            context,
            title: 'Total Done',
            value: '$totalCompleted',
            icon: Icons.check_circle_outline_rounded,
            accentColor: colorScheme.primary,
          ),
        ),
        SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: _buildStatItemCard(
            context,
            title: 'Quick Work',
            value: '$quickCompleted',
            icon: Icons.bolt_rounded,
            accentColor: colorScheme.secondary,
          ),
        ),
        SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: _buildStatItemCard(
            context,
            title: 'Project Work',
            value: '$projectCompleted',
            icon: Icons.assignment_turned_in_rounded,
            accentColor: colorScheme.tertiary,
          ),
        ),
        SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: _buildStatItemCard(
            context,
            title: 'Streak',
            value: '${streakDays}d',
            icon: Icons.local_fire_department_rounded,
            accentColor: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItemCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGithubActivityCard(BuildContext context, List<TodoModel> completedTasks) {
    final colorScheme = Theme.of(context).colorScheme;
    final activityMap = _buildActivityDateMap(completedTasks);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_on_rounded, color: colorScheme.primary, size: 22),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Activity Contribution',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 20 Weeks',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Track your daily Quick Work and Project Work productivity habits.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),

          // Heatmap Grid Matrix Widget
          _buildActivityHeatmapGrid(context, activityMap),
          SizedBox(height: AppTheme.spacingM),

          // Heatmap Legend Row
          _buildHeatmapLegend(context),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmapGrid(BuildContext context, Map<DateTime, _DailyActivity> activityMap) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate dates for 20 weeks ending today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the Monday of the week 19 weeks ago
    final currentWeekday = today.weekday; // 1 = Mon, 7 = Sun
    final startOfWeek = today.subtract(Duration(days: currentWeekday - 1));
    final startDate = startOfWeek.subtract(const Duration(days: 19 * 7));

    const totalWeeks = 20;
    const weekdays = ['Mon', 'Wed', 'Fri'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header labels row
          Row(
            children: [
              const SizedBox(width: 32), // Spacer for day labels
              ...List.generate(totalWeeks, (weekIndex) {
                final weekStartDate = startDate.add(Duration(days: weekIndex * 7));
                final isFirstWeekOfMonth = weekStartDate.day <= 7 || weekIndex == 0;
                final monthName = _getMonthName(weekStartDate.month);

                return SizedBox(
                  width: 18,
                  child: isFirstWeekOfMonth && (weekIndex == 0 || weekStartDate.day <= 7)
                      ? Text(
                          monthName,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: false,
                        )
                      : null,
                );
              }),
            ],
          ),
          const SizedBox(height: 6),

          // Heatmap Matrix Grid (7 rows x 20 columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels on left
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int d = 0; d < 7; d++)
                    SizedBox(
                      height: 18,
                      width: 28,
                      child: (d == 0 || d == 2 || d == 4)
                          ? Text(
                              weekdays[d ~/ 2],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                    ),
                ],
              ),
              const SizedBox(width: 4),

              // Matrix Columns for Weeks
              Row(
                children: List.generate(totalWeeks, (weekIndex) {
                  return Column(
                    children: List.generate(7, (dayIndex) {
                      final cellDate = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                      final normalizedDate = DateTime(cellDate.year, cellDate.month, cellDate.day);
                      final isFutureDate = normalizedDate.isAfter(today);

                      final activity = activityMap[normalizedDate] ?? const _DailyActivity(0, 0);
                      final totalCount = activity.total;

                      final cellColor = isFutureDate
                          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                          : _getHeatmapColor(colorScheme, totalCount);

                      return GestureDetector(
                        onTap: () {
                          if (!isFutureDate) {
                            _showActivityDetailsDialog(context, normalizedDate, activity);
                          }
                        },
                        child: Tooltip(
                          message: isFutureDate
                              ? 'Future Date'
                              : '$totalCount activities on ${_formatDate(normalizedDate)}',
                          child: Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: normalizedDate == today
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        _buildLegendBox(colorScheme, 0),
        _buildLegendBox(colorScheme, 1),
        _buildLegendBox(colorScheme, 2),
        _buildLegendBox(colorScheme, 4),
        _buildLegendBox(colorScheme, 6),
        const SizedBox(width: 6),
        Text(
          'More',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendBox(ColorScheme colorScheme, int count) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _getHeatmapColor(colorScheme, count),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getHeatmapColor(ColorScheme colorScheme, int count) {
    if (count == 0) {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    } else if (count == 1) {
      return colorScheme.primaryContainer.withValues(alpha: 0.5);
    } else if (count == 2 || count == 3) {
      return colorScheme.primaryContainer;
    } else if (count == 4 || count == 5) {
      return colorScheme.primary.withValues(alpha: 0.75);
    } else {
      return colorScheme.primary;
    }
  }

  Widget _buildAccountActionsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.shield_outlined, color: colorScheme.primary),
            title: Text(
              'Security & Privacy',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            onTap: () {},
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: colorScheme.error),
            title: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
            subtitle: Text(
              'Sign out from Google Auth',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: colorScheme.surface,
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out of your account?',
                    style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<AuthCubit>().logout();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showActivityDetailsDialog(
    BuildContext context,
    DateTime date,
    _DailyActivity activity,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(date),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total Activities: ${activity.total}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityDetailRow(
                context,
                title: 'Quick Work Completed',
                count: activity.quickWork,
                icon: Icons.bolt_rounded,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              _buildActivityDetailRow(
                context,
                title: 'Project Work Logged',
                count: activity.projectWork,
                icon: Icons.assignment_turned_in_rounded,
                color: colorScheme.tertiary,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityDetailRow(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, _DailyActivity> _buildActivityDateMap(List<TodoModel> completedTasks) {
    final Map<DateTime, _DailyActivity> map = {};

    for (final task in completedTasks) {
      final date = DateTime(task.endTime.year, task.endTime.month, task.endTime.day);
      final current = map[date] ?? const _DailyActivity(0, 0);

      if (task.taskType == 'quick') {
        map[date] = _DailyActivity(current.quickWork + 1, current.projectWork);
      } else {
        map[date] = _DailyActivity(current.quickWork, current.projectWork + 1);
      }
    }

    return map;
  }

  int _calculateCurrentStreak(List<TodoModel> completedTasks) {
    if (completedTasks.isEmpty) return 0;

    final dates = completedTasks
        .map((t) => DateTime(t.endTime.year, t.endTime.month, t.endTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1) % 12];
  }
}

class _DailyActivity {
  final int quickWork;
  final int projectWork;

  const _DailyActivity(this.quickWork, this.projectWork);

  int get total => quickWork + projectWork;
}
