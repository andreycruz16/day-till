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
    await _notifications.scheduleNotificationsForEvent(event);
  }

  @override
  Future<void> delete(String eventId) async {
    await _box.delete(eventId);
    await _notifications.cancelNotificationsForEvent(eventId);
  }
}
