import '../../../events/domain/entities/event_type.dart';
import '../../../events/domain/entities/reminder_option.dart';

class EventDraft {
  const EventDraft({
    required this.title,
    required this.date,
    required this.type,
    required this.isDateYearKnown,
    required this.sourceText,
    this.notificationsEnabled = false,
    this.reminder = ReminderOption.none,
    this.reminderHour,
    this.reminderMinute,
    this.notes,
    this.warnings = const [],
  });

  final String title;
  final DateTime date;
  final EventType type;
  final bool isDateYearKnown;
  final String sourceText;
  final bool notificationsEnabled;
  final ReminderOption reminder;
  final int? reminderHour;
  final int? reminderMinute;
  final String? notes;
  final List<String> warnings;
}
