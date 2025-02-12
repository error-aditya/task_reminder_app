import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await requestExactAlarmPermission();

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        print("Notification tapped: ${notificationResponse.payload}");
      },
    );

    final android = notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    android?.startForegroundService(
      0,
      notificationDetails() as String,
      'Noted',
    );
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
          await Permission.scheduleExactAlarm.request();
        }

        final androidImplementation =
            notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool canScheduleExactAlarms =
              await androidImplementation.requestPermission() ?? false;
          if (!canScheduleExactAlarms) {
            if (await Permission.scheduleExactAlarm.isDenied) {
              await Permission.scheduleExactAlarm.request();
            }
          } else {
            print("Exact alarm permission granted.");
          }
        }
      } on PlatformException catch (e) {
        print('Error requesting exact alarm permission: ${e.message}');
      }
    }
  }

  NotificationDetails notificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_notifications',
      'Task Notifications',
      channelDescription: 'Task Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'ic_launcher',
      fullScreenIntent: true,
      ongoing: false,
      enableLights: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    return const NotificationDetails(android: androidDetails, iOS: iOSDetails);
  }

  // Show notification if enabled
  Future<void> showNotification({
    int id = 0,
    String title = 'GoDo',
    String body =
        'Congratulations! You Have Set The Task.\nBest of Luck For Your Task.',
    String? payload,
  }) async {
    bool notificationsEnabled = await getNotificationSetting();
    if (notificationsEnabled) {
      await notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails(),
        payload: payload,
      );
    }
  }

  // Schedule notification if enabled
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    bool notificationsEnabled = await getNotificationSetting();
    if (notificationsEnabled) {
      final tz.TZDateTime tzScheduleDate =
          tz.TZDateTime.from(scheduleDate, tz.local);

      // ✅ Debugging log
      print(
          "⏰ Scheduling Notification at: ${tzScheduleDate.toLocal()} (${tz.local.name})");

      if (tzScheduleDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print("🚨 ERROR: Scheduled time is in the past!");
        return;
      }

      await requestExactAlarmPermission();

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduleDate,
        notificationDetails(),
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true, // ✅ Ensure this is enabled
      );

      print("✅ Notification scheduled successfully!");
    }
  }

  Future<void> toggleNotification(bool enable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled', enable);
  }

  // Get current notification setting
  Future<bool> getNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
}
