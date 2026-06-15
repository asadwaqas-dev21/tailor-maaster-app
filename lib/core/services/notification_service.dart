import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart" as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Schedule a delivery reminder
  static Future<void> scheduleDeliveryReminder({
    required int notificationId,
    required String customerName,
    required String garmentType,
    required DateTime deliveryDate,
  }) async {
    final scheduledDate = DateTime(
      deliveryDate.year,
      deliveryDate.month,
      deliveryDate.day - AppConstants.reminderDaysBefore,
      AppConstants.deliveryReminderHour,
      AppConstants.deliveryReminderMinute,
    );

    // Don't schedule if already in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: "📐 Delivery Reminder",
        body: "$customerName's $garmentType delivery is tomorrow!",
        scheduledDate: tzScheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint("Failed to schedule notification: $e");
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
