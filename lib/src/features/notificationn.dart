import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@drawable/godo');

    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await requestExactAlarmPermission();
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        final bool canScheduleExactAlarms = await notificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestPermission() ??
            false;

        if (!canScheduleExactAlarms) {
          await notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission();
        }
      } on PlatformException catch (e) {
        print('Error requesting exact alarm permission: ${e.message}');
      }
    }
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max, icon: '@drawable/godo'),
        iOS: DarwinNotificationDetails());
  }

  // Show notification if enabled
  Future<void> showNotification({
    int id = 0,
    String? title = 'GoDo',
    String? body =
        'Congratulations! You Have Set The Task.\nBest of Luck For Your Task.',
    String? payLoad,
  }) async {
    bool notificationsEnabled = await getNotificationSetting();
    if (notificationsEnabled) {
      return notificationsPlugin.show(
          id, title, body, await notificationDetails());
    }
  }

  // Schedule notification if enabled
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduleDate,
    required dynamic AndroidScheduleMode,
  }) async {
    bool notificationsEnabled = await getNotificationSetting();
    if (notificationsEnabled) {
      // Ensure the schedule date is in the future
      final tz.TZDateTime tzScheduleDate =
          tz.TZDateTime.from(scheduleDate, tz.local);
      if (tzScheduleDate.isBefore(tz.TZDateTime.now(tz.local))) {
        throw ArgumentError('scheduledDate must be a future date and time.');
      }

      await requestExactAlarmPermission();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('task_notifications', 'Task Notifications',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              icon: '@drawable/godo');

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await notificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        tzScheduleDate,
        platformChannelSpecifics,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
    }
  }

  Future<void> toggleNotification(bool enable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications_enabled', enable);
  }

  // it will get the current notification setting
  Future<bool> getNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
}
