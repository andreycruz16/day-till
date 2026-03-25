import 'package:day_till/features/events/domain/entities/event.dart';
import 'package:day_till/features/events/domain/entities/event_type.dart';
import 'package:day_till/features/events/domain/entities/reminder_option.dart';
import 'package:day_till/features/events/domain/repositories/event_repository.dart';
import 'package:day_till/features/events/domain/services/countdown_service.dart';
import 'package:day_till/features/events/presentation/providers/event_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryEventRepository repository;
  late EventListNotifier notifier;

  setUp(() {
    repository = InMemoryEventRepository();
    notifier = EventListNotifier(repository, const CountdownService());
  });

  test('saveEvent adds a new event and trims optional notes', () async {
    await notifier.saveEvent(
      title: '  Anna Birthday  ',
      date: DateTime.now().add(const Duration(days: 30)),
      type: EventType.birthday,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
      notes: '  buy cake  ',
    );

    expect(notifier.state, hasLength(1));
    expect(notifier.state.first.title, 'Anna Birthday');
    expect(notifier.state.first.notes, 'buy cake');
  });

  test('saveEvent keeps nearest event first', () async {
    final now = DateTime.now();

    await notifier.saveEvent(
      title: 'Far Event',
      date: now.add(const Duration(days: 20)),
      type: EventType.general,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
    );
    await notifier.saveEvent(
      title: 'Near Event',
      date: now.add(const Duration(days: 3)),
      type: EventType.general,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
    );

    expect(notifier.state.map((event) => event.title), [
      'Near Event',
      'Far Event',
    ]);
  });

  test('deleteEvent removes matching item', () async {
    await notifier.saveEvent(
      title: 'To Delete',
      date: DateTime.now().add(const Duration(days: 7)),
      type: EventType.general,
      reminder: ReminderOption.none,
      notificationsEnabled: false,
    );

    final eventId = notifier.state.single.id;
    await notifier.deleteEvent(eventId);

    expect(notifier.state, isEmpty);
  });
}

class InMemoryEventRepository implements EventRepository {
  final List<Event> _events = [];

  @override
  Future<void> delete(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }

  @override
  List<Event> getAll() {
    return List.unmodifiable(_events);
  }

  @override
  Event? getById(String eventId) {
    for (final event in _events) {
      if (event.id == eventId) {
        return event;
      }
    }
    return null;
  }

  @override
  Future<void> save(Event event) async {
    _events.removeWhere((current) => current.id == event.id);
    _events.add(event);
  }
}
