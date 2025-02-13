// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid,
//             iOS: initializationSettingsIOS);

//     await requestExactAlarmPermission();

//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) async {
//         print("Notification tapped: ${notificationResponse.payload}");
//       },
//     );

//     final android = notificationsPlugin.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();

//     if (android != null) {
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'foreground_channel', // ✅ Unique channel ID
//         'Foreground Service',
//         description: 'Channel for foreground service notifications',
//         importance: Importance.high,
//       );

//       await android.createNotificationChannel(channel);

//       // ✅ Start Foreground Service with a Valid ID
//       android.startForegroundService(
//         100, // ✅ Use a valid non-zero ID
//         'Foreground Notification',
//         'Noted',
//       );
//     }
//   }

//   Future<void> requestExactAlarmPermission() async {
//     if (Platform.isAndroid) {
//       try {
//         if (await Permission.notification.isDenied) {
//           await Permission.notification.request();
//           await Permission.scheduleExactAlarm.request();
//         }

//         final androidImplementation =
//             notificationsPlugin.resolvePlatformSpecificImplementation<
//                 AndroidFlutterLocalNotificationsPlugin>();

//         if (androidImplementation != null) {
//           final bool canScheduleExactAlarms =
//               await androidImplementation.requestPermission() ?? false;
//           if (!canScheduleExactAlarms) {
//             if (await Permission.scheduleExactAlarm.isDenied) {
//               await Permission.scheduleExactAlarm.request();
//             }
//           } else {
//             print("Exact alarm permission granted.");
//           }
//         }
//       } on PlatformException catch (e) {
//         print('Error requesting exact alarm permission: ${e.message}');
//       }
//     }
//   }

//   NotificationDetails notificationDetails() {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'task_notifications',
//       'Task Notifications',
//       channelDescription: 'Task Reminder Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//       icon: 'ic_launcher',
//       fullScreenIntent: true,
//       ongoing: false,
//       enableLights: true,
//     );

//     const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

//     return const NotificationDetails(android: androidDetails, iOS: iOSDetails);
//   }

//   // Show notification if enabled
//   Future<void> showNotification({
//     int id = 100,
//     String title = 'GoDo',
//     String body =
//         'Congratulations! You Have Set The Task.\nBest of Luck For Your Task.',
//     String? payload,
//   }) async {
//     bool notificationsEnabled = await getNotificationSetting();
//     if (notificationsEnabled) {
//       await notificationsPlugin.show(
//         id,
//         title,
//         body,
//         notificationDetails(),
//         payload: payload,
//       );
//     }
//   }

//   // Schedule notification if enabled
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduleDate,
//   }) async {
//     bool notificationsEnabled = await getNotificationSetting();
//     if (notificationsEnabled) {
//       final tz.TZDateTime tzScheduleDate =
//           tz.TZDateTime.from(scheduleDate, tz.local);

//       // ✅ Debugging log
//       print(
//           "⏰ Scheduling Notification at: ${tzScheduleDate.toLocal()} (${tz.local.name})");

//       if (tzScheduleDate.isBefore(tz.TZDateTime.now(tz.local))) {
//         print("🚨 ERROR: Scheduled time is in the past!");
//         return;
//       }

//       await requestExactAlarmPermission();

//       await notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tzScheduleDate,
//         notificationDetails(),
//         matchDateTimeComponents: DateTimeComponents.time,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.wallClockTime,
//         androidAllowWhileIdle: true, // ✅ Ensure this is enabled
//       );

//       print("✅ Notification scheduled successfully!");
//     }
//   }

//   Future<void> toggleNotification(bool enable) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool('notifications_enabled', enable);
//   }

//   // Get current notification setting
//   Future<bool> getNotificationSetting() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('notifications_enabled') ?? true;
//   }
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await requestPermissions();
    await requestExactAlarmPermission();
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      try {
        final androidImplementation =
            notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool canScheduleExactAlarms =
              await androidImplementation.requestExactAlarmsPermission() ??
                  false;

          if (!canScheduleExactAlarms) {
            print('Exact alarm permission denied.');
          }
        }
      } on PlatformException catch (e) {
        print('Error requesting exact alarm permission: ${e.message}');
      }
    }
  }

  /// Set Notification Details
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Show notification if enabled
  Future<void> showNotification({
    int id = 1,
    String? title = 'ToDoApp',
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
    // int id = 0,
    required String title,
    required String body,
    required DateTime scheduleDate,
    required dynamic androidScheduleMode,
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
              icon: 'ic_launcher');

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await notificationsPlugin.zonedSchedule(
        DateTime.now().microsecondsSinceEpoch % 100000,
        title,
        body,
        tzScheduleDate,
        platformChannelSpecifics,
        payload: '',
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
