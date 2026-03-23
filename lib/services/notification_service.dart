import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'ai_trainer_service.dart';

class NotificationService {
  static final NotificationService instance =
      NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  // Send an instant motivational quote notification
  Future<void> sendMotivationalQuote() async {
    final quote = AITrainerService.instance.getRandomQuote();

    const androidDetails = AndroidNotificationDetails(
      'motivation_channel',
      'Motivational Quotes',
      channelDescription:
          'Daily motivational quotes from pro bodybuilders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      0,
      '"${quote['quote']}"',
      '— ${quote['author']}',
      details,
    );
  }

  // Schedule notifications throughout the day
  Future<void> scheduleMotivationalNotifications() async {
    try {
      await _plugin.cancelAll();

      final quotes = AITrainerService.motivationalQuotes;
      final times = [8, 12, 17, 20]; // 8am, 12pm, 5pm, 8pm

      for (int i = 0; i < times.length; i++) {
        final quote = quotes[i % quotes.length];
        final scheduledTime = _nextInstanceOfTime(times[i]);

        await _plugin.zonedSchedule(
          i + 1,
          '"${quote['quote']}"',
          '— ${quote['author']}',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'motivation_channel',
              'Motivational Quotes',
              channelDescription:
                  'Daily motivational quotes from pro bodybuilders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode:
              AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      // Silently fail if scheduling is not supported
      debugPrint('Notification scheduling failed: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Helper — gets the next instance of a specific hour today or tomorrow
  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}