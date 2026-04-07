import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/notifications/local_notification_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryHive implements EventRepository {
  EventRepositoryHive(this._box, this._notifications);

  final Box<EventModel> _box;
  final LocalNotificationService _notifications;

  @override
  List<Event> getAll() {
    return _box.values.map((model) => model.toDomain()).toList();
  }

  @override
  Event? getById(String eventId) {
    return _box.get(eventId)?.toDomain();
  }

  @override
  Future<void> save(Event event) async {
    await _box.put(event.id, EventModel.fromDomain(event));
    try {
      await _notifications.scheduleNotificationsForEvent(event);
    } catch (error, stackTrace) {
      debugPrint('Event saved but notification scheduling failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> delete(String eventId) async {
    await _box.delete(eventId);
    try {
      await _notifications.cancelNotificationsForEvent(eventId);
    } catch (error, stackTrace) {
      debugPrint('Event deleted but notification cancellation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
