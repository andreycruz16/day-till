# DayTill Data Model

## Domain Entities

### Event

Represents a countdown item stored locally on the device.

```dart
enum EventType { birthday, general }

enum ReminderOption {
  none,
  sameDay,
  oneDayBefore,
  threeDaysBefore,
  oneWeekBefore,
  twoWeeksBefore,
  oneMonthBefore,
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final ReminderOption reminder;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reminderHour;
  final int reminderMinute;
  final bool isDateYearKnown;
  final String? notes;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.reminder,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.reminderHour = 6,
    this.reminderMinute = 0,
    this.isDateYearKnown = true,
    this.notes,
  });
}
```

## Important Modeling Rules

- `date` always stores a valid `DateTime`.
- For birthdays with unknown year, the app still stores a placeholder year internally, but `isDateYearKnown = false`.
- Reminder time is stored as `reminderHour` and `reminderMinute`.
- Age is only derived when the birthday year is known.

## Persistence Model

For the current app, Hive uses:

- `events` box for event records
- `settings` box for UI preferences

Example event persistence shape:

```dart
class EventModel extends HiveObject {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final ReminderOption reminder;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reminderHour;
  final int reminderMinute;
  final bool isDateYearKnown;
  final String? notes;
}
```

## Derived Fields

These are computed, not stored:

- `nextOccurrence`
- `daysRemaining`
- `activeCountdown`
- `reminderDate`
- `ageOnNextOccurrence`

## Countdown Rules

### General Event

- Uses the stored date directly.
- If the date is in the past, it is considered completed.

### Birthday

- Uses the next yearly occurrence of the stored month/day.
- If the stored month/day already passed this year, the next occurrence is in the following year.
- If the birth year is known, age is derived from `nextOccurrence.year - date.year`.

## Reminder Rules

- If `notificationsEnabled` is false, no reminder is scheduled.
- If reminders are enabled and no old reminder exists, the UI defaults to `sameDay`.
- Reminder time defaults to `6:00 AM`.
- Event-day notifications and lead-time notifications both use the stored reminder time.

## Settings Model

The current `settings` box stores lightweight preferences such as:

- `theme_mode`
- `hide_completed_events`

## Validation Rules

- `title` is required and trimmed.
- `type` is required.
- `date` is required.
- Birthday day/month combinations must remain valid for the selected or effective year.
- Reminder selection is only meaningful when reminders are enabled.

## Sample Records

Birthday with known year:

```dart
final annaBirthday = Event(
  id: 'evt_anna',
  title: 'Anna Birthday',
  date: DateTime(1995, 7, 18),
  type: EventType.birthday,
  reminder: ReminderOption.oneWeekBefore,
  notificationsEnabled: true,
  reminderHour: 6,
  reminderMinute: 0,
  isDateYearKnown: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

Birthday without known year:

```dart
final chrisBirthday = Event(
  id: 'evt_chris',
  title: 'Chris Birthday',
  date: DateTime(2000, 7, 18), // placeholder internal year
  type: EventType.birthday,
  reminder: ReminderOption.sameDay,
  notificationsEnabled: true,
  reminderHour: 6,
  reminderMinute: 0,
  isDateYearKnown: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

## Future Enhancements

- Introduce an explicit `MonthDay` value object if birthday-without-year handling becomes more central.
- Add archived/completed state for general events instead of deriving everything from date.
