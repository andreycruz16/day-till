import 'dart:io';

import 'package:day_till/core/notifications/local_notification_service.dart';
import 'package:day_till/features/events/data/models/event_model.dart';
import 'package:day_till/features/events/data/repositories/event_repository_hive.dart';
import 'package:day_till/features/events/domain/entities/event.dart';
import 'package:day_till/features/events/domain/entities/event_type.dart';
import 'package:day_till/features/events/domain/entities/reminder_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<EventModel> box;
  late FakeLocalNotificationService notifications;
  late EventRepositoryHive repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('day_till_hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EventTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ReminderOptionAdapter());
    }
  });

  setUp(() async {
    notifications = FakeLocalNotificationService();
    box = await Hive.openBox<EventModel>(
      'events_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = EventRepositoryHive(box, notifications);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('save stores event locally and schedules notifications', () async {
    final event = _sampleEvent(
      id: 'evt_1',
      title: 'Trip to Cebu',
      notificationsEnabled: true,
      reminder: ReminderOption.oneDayBefore,
    );

    await repository.save(event);

    final saved = repository.getById('evt_1');
    expect(saved, isNotNull);
    expect(saved?.title, 'Trip to Cebu');
    expect(notifications.scheduledIds, ['evt_1']);
  });

  test('delete removes event locally and cancels notifications', () async {
    final event = _sampleEvent(id: 'evt_2', title: 'Project Deadline');
    await repository.save(event);

    await repository.delete(event.id);

    expect(repository.getAll(), isEmpty);
    expect(notifications.cancelledIds, ['evt_2']);
  });
}

Event _sampleEvent({
  required String id,
  required String title,
  bool notificationsEnabled = false,
  ReminderOption reminder = ReminderOption.none,
}) {
  return Event(
    id: id,
    title: title,
    date: DateTime(2026, 4, 10),
    type: EventType.general,
    reminder: reminder,
    notificationsEnabled: notificationsEnabled,
    createdAt: DateTime(2026, 3, 26),
    updatedAt: DateTime(2026, 3, 26),
    reminderHour: 6,
    reminderMinute: 0,
    isDateYearKnown: true,
  );
}

class FakeLocalNotificationService extends LocalNotificationService {
  final List<String> scheduledIds = [];
  final List<String> cancelledIds = [];

  @override
  Future<void> scheduleNotificationsForEvent(Event event) async {
    scheduledIds.add(event.id);
  }

  @override
  Future<void> cancelNotificationsForEvent(String eventId) async {
    cancelledIds.add(eventId);
  }
}
