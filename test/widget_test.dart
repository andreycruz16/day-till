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
    );

    final days = countdownService.daysRemaining(event, DateTime(2026, 3, 26));

    expect(days, 351);
  });
}
