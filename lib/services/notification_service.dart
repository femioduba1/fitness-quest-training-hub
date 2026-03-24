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

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
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
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    // Android permissions
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS permissions
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'motivation_channel',
      'Motivational Quotes',
      description: 'Daily motivational quotes from pro bodybuilders',
      importance: Importance.high,
      playSound: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> sendMotivationalQuote() async {
    if (!_initialized) await initialize();
    await _createNotificationChannel();

    final quote = AITrainerService.instance.getRandomQuote();

    const androidDetails = AndroidNotificationDetails(
      'motivation_channel',
      'Motivational Quotes',
      channelDescription: 'Daily motivational quotes from pro bodybuilders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '"${quote['quote']}"',
        '— ${quote['author']}',
        details,
      );
      debugPrint('✅ Notification sent: ${quote['author']}');
    } catch (e) {
      debugPrint('❌ Notification failed: $e');
    }
  }

  Future<void> scheduleMotivationalNotifications() async {
    if (!_initialized) await initialize();
    await _createNotificationChannel();

    try {
      await _plugin.cancelAll();

      final quotes = AITrainerService.motivationalQuotes;
      final times = [8, 12, 17, 20];

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
              channelDescription: 'Daily motivational quotes from pro bodybuilders',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('✅ Scheduled at ${times[i]}:00');
      }
    } catch (e) {
      debugPrint('❌ Scheduling failed: $e');
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedules a weekly Sunday notification to remind user to log weight
Future<void> scheduleSundayWeightReminder() async {
  if (!_initialized) await initialize();
  await _createNotificationChannel();

  try {
    final now = tz.TZDateTime.now(tz.local);

    // Find next Sunday at 9am
    var nextSunday = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 9);

    // days until Sunday (weekday: 1=Mon, 7=Sun)
    final daysUntilSunday = (7 - now.weekday) % 7;
    nextSunday = nextSunday
        .add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));

    await _plugin.zonedSchedule(
      99, // unique ID for weight reminder
      '⚖️ Weekly Weigh-In Reminder',
      'Time to log your weight and track your BMI progress!',
      nextSunday,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_reminder_channel',
          'Weight Reminders',
          channelDescription: 'Weekly Sunday weight logging reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint('✅ Sunday weight reminder scheduled');
  } catch (e) {
    debugPrint('❌ Weight reminder scheduling failed: $e');
  }
}
}