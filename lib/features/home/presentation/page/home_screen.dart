import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/add_todo/data/todo.dart';
import 'package:todo/features/auth/presentation/logic/auth_cubit.dart';
import 'package:todo/features/auth/presentation/logic/auth_state.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/home/presentation/page/details_page.dart';
import 'package:todo/features/home/presentation/page/widgets/category_style.dart';
import 'package:todo/features/home/presentation/page/widgets/shake_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _getUrgencyPriority(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'Urgent Important':
        return 1;
      case 'Not Important Urgent':
        return 2;
      case 'Not Urgent Important':
        return 3;
      case 'Not Important Not Urgent':
        return 4;
      default:
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final String displayName =
            authState is AuthAuthenticated
                ? authState.user.displayName
                : 'Guest';

        final String? photoUrl =
            authState is AuthAuthenticated ? authState.user.photoUrl : null;

        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child:
                    photoUrl == null
                        ? Icon(
                          Icons.person_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        )
                        : null,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 26,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard({
    required ElementTask task,
    required CategoryStyle style,
    required double progress,
    required bool isUrgentImportant,
  }) {
    return OpenContainer<void>(
      closedElevation: 0,
      openElevation: 0,
      transitionDuration: const Duration(milliseconds: 450),
      closedColor: Colors.transparent,
      openColor: Theme.of(context).colorScheme.surfaceBright,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      closedBuilder: (context, openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border:
                  isUrgentImportant
                      ? Border.all(color: Theme.of(context).colorScheme.error, width: 1.5)
                      : null,
              image: DecorationImage(
                image: AssetImage(
                  categoryImageMap[task.category] ?? 'assets/Personal.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isUrgentImportant
                          ? Theme.of(context).colorScheme.error.withValues(alpha: 0.25)
                          : style.progressColor.withValues(alpha: 0.05),
                  blurRadius: isUrgentImportant ? 14 : 10,
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
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              style.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          if (isUrgentImportant) ...[
                            SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style.icon, size: 12, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Expanded(
                  child: Text(
                    task.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgentImportant
                          ? Theme.of(context).colorScheme.error
                          : style.progressColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, _) => DetailsPage(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      body: SafeArea(
        child: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            List<ElementTask> inProgressTasks = [];
            double completionRate = 0.0;

            if (state is TodoLoaded) {
              final tasks = state.tasks;
              final totalTasks = tasks.length;
              final completedTasks = tasks.where((t) => !t.isPending).length;
              inProgressTasks =
                  tasks.where((t) => t.isPending).toList()..sort((a, b) {
                    final priorityA = _getUrgencyPriority(a.urgencyLevel);
                    final priorityB = _getUrgencyPriority(b.urgencyLevel);
                    if (priorityA != priorityB) {
                      return priorityA.compareTo(priorityB);
                    }
                    return a.startTime.compareTo(b.startTime);
                  });
              completionRate =
                  totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header
                  _buildProfileHeader(),
                  SizedBox(height: 24),

                  // 2. Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your today\'s task\nalmost done!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 18),
                              SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push('/profile');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: Text(
                                    'Show Analytics',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: CircularProgressIndicator(
                                value: completionRate,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                color: Colors.white,
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${(completionRate * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // 3. In Progress Section
                  Row(
                    children: [
                      Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${inProgressTasks.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (state is TodoLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  else if (state is TaskError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Failed to load tasks: ${state.message ?? 'Unknown error'}',
                        ),
                      ),
                    )
                  else if (state is TodoEmpty || inProgressTasks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_todo.png',
                            height: 350,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No tasks in progress today! 🎉',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                      itemCount: inProgressTasks.length,
                      itemBuilder: (context, index) {
                        final task = inProgressTasks[index];
                        final style = getCategoryStyle(task.category);

                        // Calculate time elapsed ratio
                        final totalDuration =
                            task.endTime.difference(task.startTime).inMinutes;
                        final elapsed =
                            DateTime.now().difference(task.startTime).inMinutes;
                        double progress = 0.5;
                        if (totalDuration > 0) {
                          progress = (elapsed / totalDuration).clamp(0.1, 0.9);
                        }

                        final isUrgentImportant =
                            task.urgencyLevel == 'Urgent Important';

                        return ShakeWidget(
                          shake: isUrgentImportant,
                          child: _buildTaskCard(
                            task: task,
                            style: style,
                            progress: progress,
                            isUrgentImportant: isUrgentImportant,
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
