# DayTill Data Model

## Domain Entities

### Event

Represents a countdown item stored locally on device.

```dart
enum EventType {
  birthday,
  general,
}

enum ReminderOption {
  none,
  sameDay,
  oneDayBefore,
  threeDaysBefore,
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final String? notes;
  final ReminderOption reminder;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.notes,
    required this.reminder,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

## Persistence Model

Hive stores a serialized event record. For this POC, one box named `events` is sufficient.

```dart
@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int typeIndex;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  int reminderIndex;

  @HiveField(6)
  bool notificationsEnabled;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.typeIndex,
    this.notes,
    required this.reminderIndex,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

## Derived Fields

These values do not need to be stored permanently:

- `daysRemaining`
- `nextOccurrence`
- `isPast`

They should be computed in domain logic based on current device date.

## Countdown Rules

### General Event

- Use the stored date directly.
- If the date is in the past, mark the event as expired or completed.

### Birthday

- Compute the next occurrence using the month and day in the current year.
- If that date has already passed, use the same month and day in the next year.

## Notification Mapping

- Each event needs at least one deterministic notification ID.
- Optional reminder notifications should use a second deterministic ID derived from the event ID.

Example strategy:

```dart
int eventDayNotificationId(String eventId) => eventId.hashCode;
int reminderNotificationId(String eventId) => eventId.hashCode ^ 0x7fffffff;
```

## Validation Rules

- `title` is required and should be trimmed.
- `date` is required.
- `type` is required.
- `notes` is optional.
- Reminder scheduling is only valid when notifications are enabled.

## Sample Record

```dart
final birthday = Event(
  id: 'evt_001',
  title: 'Anna Birthday',
  date: DateTime(1995, 7, 18),
  type: EventType.birthday,
  notes: 'Buy cake',
  reminder: ReminderOption.oneDayBefore,
  notificationsEnabled: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Future Enhancements

- Add event color or icon metadata.
- Add `isArchived` for hiding past one-time events.
- Add richer recurrence rules if the product expands.
