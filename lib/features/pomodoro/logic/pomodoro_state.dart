part of 'pomodoro_cubit.dart';

class PomodoroState {
  final PomodoroMode mode;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final int completedSessions;

  const PomodoroState({
    required this.mode,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    this.completedSessions = 0,
  });

  factory PomodoroState.initial() {
    const PomodoroMode defaultMode = PomodoroMode.focus;

    final int total = defaultMode.defaultMinutes * 60;

    return PomodoroState(
      mode: defaultMode,
      totalSeconds: total,
      remainingSeconds: total,
      isRunning: false,
      completedSessions: 0,
    );
  }

  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  String get formattedTime {
    final String minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final String seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  PomodoroState copyWith({
    PomodoroMode? mode,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    int? completedSessions,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }
}

enum PomodoroMode { focus, shortBreak, longBreak }
