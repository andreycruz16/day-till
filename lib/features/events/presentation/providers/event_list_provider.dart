import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/notifications/local_notification_service.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository_hive.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/reminder_option.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/services/countdown_service.dart';

final countdownServiceProvider = Provider((ref) => const CountdownService());

enum EventListFilter { all, birthdays, events }

final eventListFilterProvider = StateProvider<EventListFilter>(
  (ref) => EventListFilter.all,
);

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final box = Hive.box<EventModel>('events');
  final notifications = ref.watch(localNotificationServiceProvider);
  return EventRepositoryHive(box, notifications);
});

final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>(
  (ref) {
    final repository = ref.watch(eventRepositoryProvider);
    final countdownService = ref.watch(countdownServiceProvider);
    return EventListNotifier(repository, countdownService);
  },
);

class EventListNotifier extends StateNotifier<List<Event>> {
  EventListNotifier(this._repository, this._countdownService)
    : super(_sortedEvents(_repository.getAll(), _countdownService));

  final EventRepository _repository;
  final CountdownService _countdownService;

  Future<void> saveEvent({
    required String title,
    required DateTime date,
    required EventType type,
    required ReminderOption reminder,
    required bool notificationsEnabled,
    String? notes,
    Event? existing,
  }) async {
    final now = DateTime.now();
    final trimmedNotes = notes?.trim();
    final normalizedNotes = trimmedNotes == null || trimmedNotes.isEmpty
        ? null
        : trimmedNotes;

    final event =
        existing?.copyWith(
          title: title.trim(),
          date: date,
          type: type,
          reminder: reminder,
          notificationsEnabled: notificationsEnabled,
          updatedAt: now,
          notes: normalizedNotes,
          clearNotes: normalizedNotes == null,
        ) ??
        Event(
          id: _generateEventId(),
          title: title.trim(),
          date: date,
          type: type,
          reminder: reminder,
          notificationsEnabled: notificationsEnabled,
          createdAt: now,
          updatedAt: now,
          notes: normalizedNotes,
        );

    await _repository.save(event);
    _reload();
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.delete(eventId);
    _reload();
  }

  void _reload() {
    state = _sortedEvents(_repository.getAll(), _countdownService);
  }

  static List<Event> _sortedEvents(
    List<Event> events,
    CountdownService countdownService,
  ) {
    final now = DateTime.now();
    final sorted = [...events];
    sorted.sort((a, b) {
      final dayComparison = countdownService
          .daysRemaining(a, now)
          .compareTo(countdownService.daysRemaining(b, now));
      if (dayComparison != 0) {
        return dayComparison;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return sorted;
  }

  String _generateEventId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomPart = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'evt_${timestamp}_$randomPart';
  }
}
