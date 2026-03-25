import 'package:day_till/features/events/domain/entities/event.dart';
import 'package:day_till/features/events/domain/entities/event_type.dart';
import 'package:day_till/features/events/domain/entities/reminder_option.dart';
import 'package:day_till/features/events/domain/services/countdown_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const countdownService = CountdownService();

  test('general event countdown uses stored date', () {
    final event = Event(
      id: 'event_1',
      title: 'Trip',
      date: DateTime(2026, 4, 1),
      type: EventType.general,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 20),
      reminderHour: 6,
      reminderMinute: 0,
      isDateYearKnown: true,
    );

    final days = countdownService.daysRemaining(event, DateTime(2026, 3, 26));

    expect(days, 6);
  });

  test('birthday countdown rolls to next year when needed', () {
    final event = Event(
      id: 'event_2',
      title: 'Anna Birthday',
      date: DateTime(1995, 3, 12),
      type: EventType.birthday,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 20),
      reminderHour: 6,
      reminderMinute: 0,
      isDateYearKnown: true,
    );

    final days = countdownService.daysRemaining(event, DateTime(2026, 3, 26));

    expect(days, 351);
  });

  test('active countdown shows day and time for future event', () {
    final event = Event(
      id: 'event_3',
      title: 'Launch',
      date: DateTime(2026, 3, 28),
      type: EventType.general,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 20),
      reminderHour: 6,
      reminderMinute: 0,
      isDateYearKnown: true,
    );

    final countdown = countdownService.formatActiveCountdown(
      event,
      DateTime(2026, 3, 26, 12, 0, 0),
    );

    expect(countdown, '1d 12h 0m');
  });

  test('birthday age is hidden when birth year is unknown', () {
    final event = Event(
      id: 'event_4',
      title: 'Chris Birthday',
      date: DateTime(2000, 7, 18),
      type: EventType.birthday,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 20),
      reminderHour: 6,
      reminderMinute: 0,
      isDateYearKnown: false,
    );

    expect(event.ageOnNextOccurrence(), isNull);
  });
}
