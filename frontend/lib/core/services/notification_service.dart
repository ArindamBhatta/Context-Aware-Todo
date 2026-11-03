import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Used for time zone initialization
import 'package:timezone/data/latest_all.dart' as tz;
// Used for time zone operations
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/features/add_todo/data/model/todo.dart';

class NotificationService {
  // Private constructor to prevent direct instantiation
  NotificationService._internal();

  // Singleton instance for Notification Service
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor to return the singleton instance
  factory NotificationService() {
    return _instance;
  }

  // Instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Flag to check if notification service is initialized
  bool _initialized = false;

  //? Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    // help to understand local time zones
    tz.initializeTimeZones();

    // Android Initialization Settings is used to initialize the Android part of the plugin.
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization Settings is used to initialize the iOS part of the plugin.
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialization Settings is used to initialize the plugin.
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    // initialize the plugin
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Request permissions for Android 13+
    final androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  // Why scheduleNotification is needed: When a user minimizes a Flutter app (putting it in the background) or swipes it away to close it, the phone's operating system pauses or kills all Dart code. That means your Timer.periodic stops counting! By calling scheduleNotification, you are handing the countdown over to the Android/iOS system itself, which never goes to sleep.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration,
  }) async {
    // Initialize notification service
    await init();

    // Android Notification Details is used to configure the Android part of the notification.
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Timer Notifications',
          channelDescription:
              'Notifications for completed Pomodoro timer sessions',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    // Notification Details is used to configure the notification.
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    //checks my device's system clock right now. add(duration) takes that current time and adds the 25 minutes to it.
    final scheduledTime = tz.TZDateTime.now(tz.local).add(duration);

    //passes that scheduledTime to your phone's operating system (Android or iOS).
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  //Why showNotification is needed: If the user leaves the app open on their screen the entire time, your Timer.periodic counts all the way down to zero. When it hits 0, you use showNotification to pop the alert instantly on their screen.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Initialize notification service
    await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Timer Notifications',
          channelDescription:
              'Notifications for completed Pomodoro timer sessions',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Schedules a 50% lapsed local notification for Quick Work tasks
  Future<void> scheduleQuickWork50PercentNotification(TodoModel task) async {
    if (task.taskType != 'quick' || !task.isPending) return;

    final int totalSeconds = task.endTime.difference(task.startTime).inSeconds;
    if (totalSeconds <= 0) return;

    final int midpointSeconds = (totalSeconds / 2).round();
    final DateTime midpointTime = task.startTime.add(Duration(seconds: midpointSeconds));
    final DateTime now = DateTime.now();

    final Duration remainingToMidpoint = midpointTime.difference(now);
    final int notificationId = task.id.hashCode.abs();

    if (remainingToMidpoint > Duration.zero) {
      await scheduleNotification(
        id: notificationId,
        title: '⏳ Quick Work 50% Time Lapsed!',
        body: 'Your 50% time for "${task.name}" is lapsed. You have 50% time in your hand.',
        duration: remainingToMidpoint,
      );
    }
  }

  /// Cancels scheduled 50% lapsed notification for a specific task
  Future<void> cancelQuickWorkNotification(String taskId) async {
    final int notificationId = taskId.hashCode.abs();
    await cancelNotification(notificationId);
  }
}

