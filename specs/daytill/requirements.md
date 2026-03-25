# DayTill Requirements

## Functional Requirements

### Event Management

- Users can create, edit, and delete events.
- Each event has a title, date information, event type, optional notes, and optional local reminder settings.
- General events use a full date.
- Birthdays use month and day, with an optional birth year.

### Countdown Display

- The home screen shows saved events ordered by nearest upcoming occurrence.
- Each item shows a day-based countdown label such as `Today`, `Tomorrow`, or `12 days`.
- Each item also shows a live countdown string that updates automatically over time.
- Birthday items calculate against the next yearly occurrence.
- If a birthday includes a known birth year, the app shows the age for the next occurrence.

### Event Types

- `birthday` events are treated as recurring yearly countdowns.
- `general` events are treated as one-time events.
- Birthdays can be stored with an unknown birth year while still supporting countdowns.

### Reminders

- Users can enable or disable reminders per event.
- When reminders are enabled, the default reminder lead time is `On event day`.
- Users can choose from multiple reminder lead times:
  - on event day
  - 1 day before
  - 3 days before
  - 1 week before
  - 2 weeks before
  - 1 month before
- Users can choose a reminder time, defaulting to `6:00 AM`.
- Editing or deleting an event updates or cancels scheduled notifications.

### Homepage Filtering

- Users can filter the home list by `All`, `Birthdays`, or `Events`.
- Users can choose in Settings whether completed events should be hidden on the homepage.

### Settings

- Users can toggle dark mode.
- Users can toggle hiding completed events on the homepage.
- Settings persist across app launches.

## Non-Functional Requirements

### Offline Operation

- All primary features work without network access.
- No backend services or external APIs are required.

### Performance

- App startup should remain fast for a small local dataset.
- Countdown updates should use a lightweight shared timer rather than a per-item timer model.

### Usability

- Primary actions should be reachable within 1-2 taps from the home screen.
- The event form should remain simple even with birthday and reminder-specific options.
- Dark mode should preserve readable contrast for cards, chips, and countdown UI.

### Maintainability

- Code should keep presentation, domain, and data concerns separated.
- Hive schema evolution must remain backward-compatible where practical.
- Business rules such as birthday recurrence, age calculation, and reminder timing should live outside widgets.

## Acceptance Criteria

- A user can create a birthday without knowing the birth year.
- A user can create a birthday with a birth year and see the next age on the home card.
- A user can enable reminders and choose both lead time and reminder time.
- The homepage filter chips update the visible list immediately.
- The `Hide completed events` setting affects the homepage without requiring app restart.
- Existing locally stored events continue loading after model changes.

## Future Enhancements

- Sort options and search
- Notification preview or test reminder
- Backup and restore
- App lock or privacy options
