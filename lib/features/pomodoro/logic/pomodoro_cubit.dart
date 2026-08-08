import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/services/notification_service.dart';

part 'pomodoro_state.dart';

extension PomodoroModeX on PomodoroMode {
  int get defaultMinutes {
    switch (this) {
      case PomodoroMode.focus:
        return 25;
      case PomodoroMode.shortBreak:
        return 5;
      case PomodoroMode.longBreak:
        return 15;
    }
  }

  String get label {
    switch (this) {
      case PomodoroMode.focus:
        return 'Focus';
      case PomodoroMode.shortBreak:
        return 'Short Break';
      case PomodoroMode.longBreak:
        return 'Long Break';
    }
  }

  String get completionNotificationTitle {
    switch (this) {
      case PomodoroMode.focus:
        return '🔔 Focus session complete!';
      case PomodoroMode.shortBreak:
        return '☕ Short break complete!';
      case PomodoroMode.longBreak:
        return '🎉 Long break complete!';
    }
  }

  String get completionNotificationBody {
    switch (this) {
      case PomodoroMode.focus:
        return 'Great job staying focused! Time to take a break.';
      case PomodoroMode.shortBreak:
        return 'Break is over. Ready to dive back in?';
      case PomodoroMode.longBreak:
        return 'Rest time is over! Ready to start a new focus session?';
    }
  }
}

class PomodoroCubit extends Cubit<PomodoroState> {
  // Timer for the pomodoro
  Timer? _timer;
  //Notification service for the pomodoro
  final NotificationService _notificationService;
  // Notification id for the pomodoro
  static const int _notificationId = 1001;

  PomodoroCubit({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService(),
      super(PomodoroState.initial());

  void setMode(PomodoroMode mode) {
    _timer?.cancel();
    _notificationService.cancelNotification(_notificationId);

    final int totalSeconds = mode.defaultMinutes * 60;

    //? Update the state with the new mode
    emit(
      state.copyWith(
        mode: mode,
        totalSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
        isRunning: false,
      ),
    );
  }

  void startTimer() {
    if (state.isRunning || state.remainingSeconds <= 0) return;

    _timer?.cancel();

    //? Schedule local system notification so Android/iOS Notification Manager triggers it even if app is backgrounded or closed.
    _notificationService.scheduleNotification(
      id: _notificationId,
      title: state.mode.completionNotificationTitle,
      body: state.mode.completionNotificationBody,
      duration: Duration(seconds: state.remainingSeconds),
    );

    emit(state.copyWith(isRunning: true));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        //? This is for Android and iOS to show notification when app is open
        _notificationService.showNotification(
          id: _notificationId,
          title: state.mode.completionNotificationTitle,
          body: state.mode.completionNotificationBody,
        );
        final newCompleted =
            state.mode == PomodoroMode.focus
                ? state.completedSessions + 1
                : state.completedSessions;
        emit(
          state.copyWith(
            remainingSeconds: 0,
            isRunning: false,
            completedSessions: newCompleted,
          ),
        );
      } else {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _notificationService.cancelNotification(_notificationId);
    emit(state.copyWith(isRunning: false));
  }

  void resetTimer() {
    _timer?.cancel();
    _notificationService.cancelNotification(_notificationId);
    emit(
      state.copyWith(remainingSeconds: state.totalSeconds, isRunning: false),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
