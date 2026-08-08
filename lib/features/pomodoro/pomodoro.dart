import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/pomodoro/logic/pomodoro_cubit.dart';

class Pomodoro extends StatelessWidget {
  const Pomodoro({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PomodoroView();
  }
}

class _PomodoroView extends StatefulWidget {
  const _PomodoroView();

  @override
  State<_PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<_PomodoroView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Visual Theme Helper based on selected PomodoroMode
  _PomodoroTheme _getThemeForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return _PomodoroTheme(
          primary: Theme.of(context).colorScheme.primary,
          secondary: Theme.of(context).colorScheme.secondary,
          accentGradient: [
            Theme.of(context).colorScheme.primary,
            Color(0xFF9333EA),
          ],
          bgTint: Color(0xFFF5F3FF),
          badgeText: 'FOCUS SESSION',
          icon: Icons.psychology_rounded,
          subtitle: 'Stay focused and eliminate distractions',
        );
      case PomodoroMode.shortBreak:
        return const _PomodoroTheme(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF059669),
          accentGradient: [Color(0xFF10B981), Color(0xFF14B8A6)],
          bgTint: Color(0xFFECFDF5),
          badgeText: 'SHORT BREAK',
          icon: Icons.coffee_rounded,
          subtitle: 'Take a deep breath and stretch your muscles',
        );
      case PomodoroMode.longBreak:
        return _PomodoroTheme(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFFD97706),
          accentGradient: [
            Color(0xFFF59E0B),
            Theme.of(context).colorScheme.error,
          ],
          bgTint: Color(0xFFFFFBEB),
          badgeText: 'LONG BREAK',
          icon: Icons.beach_access_rounded,
          subtitle: 'Rest up, grab a snack, and recharge',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        title: Text(
          'Pomodoro Focus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<PomodoroCubit, PomodoroState>(
          builder: (context, state) {
            final cubit = context.read<PomodoroCubit>();
            final theme = _getThemeForMode(state.mode);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // 1. Top Subtitle Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.bgTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(theme.icon, size: 18, color: theme.primary),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            theme.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // 2. Custom Mode Switcher Tabs
                  _buildModeSelector(context, state.mode, cubit, theme),
                  SizedBox(height: 36),

                  // 3. Hero Circular Timer Display
                  _buildTimerRing(context, state, theme),
                  SizedBox(height: 40),

                  // 4. Interactive Action Controls
                  _buildActionControls(context, state, cubit, theme),
                  SizedBox(height: 32),

                  // 5. Stat Cards
                  _buildInfoCards(state, theme),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    PomodoroMode currentMode,
    PomodoroCubit cubit,
    _PomodoroTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children:
            PomodoroMode.values.map((mode) {
              final isSelected = currentMode == mode;
              final modeTheme = _getThemeForMode(mode);

              return Expanded(
                child: GestureDetector(
                  onTap: () => cubit.setMode(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? modeTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: modeTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          modeTheme.icon,
                          size: 16,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 6),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTimerRing(
    BuildContext context,
    PomodoroState state,
    _PomodoroTheme theme,
  ) {
    final progress = state.progress;

    return Center(
      child: SizedBox(
        width: 270,
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ambient glow behind timer when running
            if (state.isRunning)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withValues(
                            alpha: 0.15 + (_pulseController.value * 0.12),
                          ),
                          blurRadius: 30 + (_pulseController.value * 15),
                          spreadRadius: 5 + (_pulseController.value * 5),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Custom Painter Progress Ring
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: progress, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, animValue, child) {
                return CustomPaint(
                  size: const Size(260, 260),
                  painter: _PomodoroProgressPainter(
                    progress: animValue,
                    primaryColor: theme.primary,
                    secondaryColor: theme.secondary,
                    trackColor: theme.primary.withValues(alpha: 0.12),
                  ),
                );
              },
            ),

            // Center Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    theme.badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Monospace Timer Text
                Text(
                  state.formattedTime,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(height: 8),

                // Status Pill
                _buildStatusPill(state, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(PomodoroState state, _PomodoroTheme theme) {
    String statusText = 'READY TO START';
    Color dotColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (state.isRunning) {
      statusText = 'IN PROGRESS';
      dotColor = theme.primary;
    } else if (state.remainingSeconds < state.totalSeconds &&
        state.remainingSeconds > 0) {
      statusText = 'PAUSED';
      dotColor = const Color(0xFFF59E0B);
    } else if (state.remainingSeconds == 0) {
      statusText = 'FINISHED!';
      dotColor = const Color(0xFF10B981);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.isRunning)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor.withValues(
                    alpha: 0.4 + (_pulseController.value * 0.6),
                  ),
                ),
              );
            },
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
        SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildActionControls(
    BuildContext context,
    PomodoroState state,
    PomodoroCubit cubit,
    _PomodoroTheme theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button
        IconButton(
          onPressed: cubit.resetTimer,
          iconSize: 22,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF475569),
            padding: const EdgeInsets.all(16),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            side: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          icon: Icon(Icons.replay_rounded),
          tooltip: 'Reset Timer',
        ),

        SizedBox(width: 24),

        // Hero Start / Pause Button
        GestureDetector(
          onTap: state.isRunning ? cubit.pauseTimer : cubit.startTimer,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: theme.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(width: 24),

        // Skip / Next Mode Button
        IconButton(
          onPressed: () {
            // Cycle to next mode
            final nextIndex =
                (state.mode.index + 1) % PomodoroMode.values.length;
            cubit.setMode(PomodoroMode.values[nextIndex]);
          },
          iconSize: 22,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF475569),
            padding: const EdgeInsets.all(16),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            side: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          icon: Icon(Icons.skip_next_rounded),
          tooltip: 'Next Mode',
        ),
      ],
    );
  }

  Widget _buildInfoCards(PomodoroState state, _PomodoroTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stat 1: Duration
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.bgTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: theme.primary,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${state.mode.defaultMinutes} min',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            height: 36,
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),

          // Stat 2: Progress %
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${((1 - state.progress) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Visual Theme Container model
class _PomodoroTheme {
  final Color primary;
  final Color secondary;
  final List<Color> accentGradient;
  final Color bgTint;
  final String badgeText;
  final IconData icon;
  final String subtitle;

  const _PomodoroTheme({
    required this.primary,
    required this.secondary,
    required this.accentGradient,
    required this.bgTint,
    required this.badgeText,
    required this.icon,
    required this.subtitle,
  });
}

// Custom Ring Progress Painter
class _PomodoroProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;

  _PomodoroProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // 1. Draw Track Ring
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw Active Progress Arc
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;

      final progressPaint =
          Paint()
            ..shader = SweepGradient(
              colors: [secondaryColor, primaryColor, secondaryColor],
              startAngle: -math.pi / 2,
              endAngle: 3 * math.pi / 2,
            ).createShader(Rect.fromCircle(center: center, radius: radius))
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PomodoroProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
