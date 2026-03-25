import 'event_type.dart';
import 'reminder_option.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.reminder,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final ReminderOption reminder;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    EventType? type,
    ReminderOption? reminder,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool clearNotes = false,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      reminder: reminder ?? this.reminder,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }

  DateTime get nextOccurrence {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (type == EventType.general) {
      return DateTime(date.year, date.month, date.day);
    }

    var nextBirthday = DateTime(today.year, date.month, date.day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, date.month, date.day);
    }
    return nextBirthday;
  }

  DateTime? get reminderDate {
    if (!notificationsEnabled || reminder.daysBefore == null) {
      return null;
    }

    return nextOccurrence.subtract(Duration(days: reminder.daysBefore!));
  }
}
