import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/events/domain/entities/event.dart';
import '../../features/events/domain/entities/event_type.dart';
import '../../features/events/domain/entities/reminder_option.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => throw UnimplementedError('Notification service not initialized'),
);

class LocalNotificationService {
  LocalNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleNotificationsForEvent(Event event) async {
    if (!event.notificationsEnabled) {
      await cancelNotificationsForEvent(event.id);
      return;
    }

    await _scheduleNotification(
      id: eventDayNotificationId(event.id),
      title: event.title,
      body: _eventDayBody(event),
      scheduledDate: event.nextOccurrence,
      hour: event.reminderHour,
      minute: event.reminderMinute,
    );

    final reminderDate = event.reminderDate;
    if (reminderDate == null) {
      await _plugin.cancel(reminderNotificationId(event.id));
      return;
    }

    await _scheduleNotification(
      id: reminderNotificationId(event.id),
      title: 'Upcoming: ${event.title}',
      body: _reminderBody(event.reminder),
      scheduledDate: reminderDate,
      hour: event.reminderHour,
      minute: event.reminderMinute,
    );
  }

  Future<void> cancelNotificationsForEvent(String eventId) async {
    await _plugin.cancel(eventDayNotificationId(eventId));
    await _plugin.cancel(reminderNotificationId(eventId));
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    final scheduleAt = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );
    if (!scheduleAt.isAfter(now)) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'day_till_reminders',
        'DayTill Reminders',
        channelDescription: 'Countdown reminders for events and birthdays',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduleAt, tz.local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('Notification scheduling failed: $error');
    }
  }

  String _eventDayBody(Event event) {
    return switch (event.type) {
      EventType.birthday => 'Today is ${event.title}.',
      EventType.general => '${event.title} is happening today.',
    };
  }

  String _reminderBody(ReminderOption reminder) {
    return switch (reminder) {
      ReminderOption.none => 'Your event is coming up soon.',
      ReminderOption.sameDay => 'Happening today.',
      ReminderOption.oneDayBefore => 'Happening tomorrow.',
      ReminderOption.threeDaysBefore => 'Only 3 days left.',
      ReminderOption.oneWeekBefore => 'Only 1 week left.',
      ReminderOption.twoWeeksBefore => 'Only 2 weeks left.',
      ReminderOption.oneMonthBefore => 'Only 1 month left.',
    };
  }
}

int eventDayNotificationId(String eventId) => eventId.hashCode & 0x7fffffff;

int reminderNotificationId(String eventId) =>
    (eventId.hashCode ^ 0x7fffffff) & 0x7fffffff;
