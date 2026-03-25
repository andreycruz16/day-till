import '../entities/event.dart';

abstract class EventRepository {
  List<Event> getAll();
  Event? getById(String eventId);
  Future<void> save(Event event);
  Future<void> delete(String eventId);
}
