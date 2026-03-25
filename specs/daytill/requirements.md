# DayTill Requirements

## Functional Requirements

### Event Management

- Users can create a new event with a title, date, type, optional notes, and optional reminder.
- Users can edit an existing event.
- Users can delete an existing event.

### Countdown Display

- The app shows the number of days remaining until each event.
- Countdown values update correctly based on the device date.
- Events are displayed in a list ordered by nearest upcoming date.
- Past general events may be shown as completed or expired.
- Birthday events should calculate against the next yearly occurrence.

### Event Types

- `birthday` events are treated as recurring yearly countdowns.
- `general` events are treated as one-time events by default.

### Notifications

- Users can enable or disable reminders per event.
- The app schedules a notification on the event day.
- The app can optionally schedule a reminder before the event day.
- Editing an event updates its scheduled notifications.
- Deleting an event cancels its scheduled notifications.

## Non-Functional Requirements

### Offline Operation

- All app features must work without internet access.
- No backend services or APIs are required.

### Performance

- Cold start target: under 2 seconds on a typical device.
- Event list rendering should remain smooth for small-to-medium personal datasets.

### Usability

- UI should be clean, minimal, and easy to understand.
- Primary actions should be reachable within 1-2 taps from the home screen.
- Forms should validate required fields before save.

### Maintainability

- Code should follow clean architecture boundaries.
- Business logic should be testable without UI dependencies.
- Platform-specific notification logic should be isolated behind abstractions.

## Assumptions

- Primary use is on Android and iOS phones.
- Device timezone and system clock are the source of truth.
- Local notifications depend on OS permissions and platform behavior.

## Acceptance Criteria

- A user can add an event and immediately see it in the countdown list.
- A user can edit or delete an event and see the UI update without restarting the app.
- Birthday countdowns roll forward to the next occurrence after the current year’s date passes.
- Notifications are scheduled, updated, and canceled consistently for enabled events.

## Future Enhancements

- Recurring events beyond birthdays.
- Search, sort, and category filters.
- Richer reminder options such as 1 day, 3 days, or 1 week before.
- Backup and restore.
