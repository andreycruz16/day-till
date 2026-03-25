# DayTill Design Decisions

## Decision Summary

- Flutter is used for a single offline-capable mobile codebase.
- Clean architecture is used, but in a deliberately lightweight form.
- Hive persists both events and simple settings.
- Birthday recurrence is handled by domain rules rather than recurrence infrastructure.
- Birthdays support unknown year while still preserving month/day countdown behavior.
- Live countdowns use one shared clock provider instead of per-item timers.

## 1. Keep Architecture Lightweight

### Decision

Use presentation, domain, and data layers, but avoid extra use-case classes unless complexity grows.

### Rationale

- Matches the size of the app
- Keeps business rules testable
- Keeps implementation speed high

### Tradeoff

- Some responsibilities sit in providers/services instead of more formal application classes

## 2. Use Hive for Both Events and Settings

### Decision

Persist events and basic user preferences locally in Hive.

### Rationale

- One storage technology is enough for the current scope
- Fast local reads/writes
- Good fit for fully offline behavior

### Tradeoff

- Schema evolution requires manual care

## 3. Represent Birthdays with Optional Known Year

### Decision

Support birthdays where the month/day is known but the birth year is not.

### Rationale

- Matches real-world usage
- Preserves birthday countdown usefulness without forcing users to guess a year

### Tradeoff

- Requires an extra boolean flag and UI logic for effective year handling

## 4. Show Age Only When It Is Safe to Compute

### Decision

Display age for birthdays only when the birth year is known.

### Rationale

- Prevents misleading or fabricated age values
- Keeps birthday cards more useful when the year is available

### Tradeoff

- UI must branch between known-year and unknown-year birthday presentation

## 5. Use a Shared Clock Provider for Live Countdowns

### Decision

Drive active countdown updates from a single shared Riverpod clock stream.

### Rationale

- Simpler than per-card timers
- Reduces duplicated timer logic
- Keeps the homepage implementation predictable

### Tradeoff

- The list rebuilds on each tick while visible

## 6. Tie Reminder Scheduling to Event-Level Time

### Decision

Store reminder hour and minute per event and use them for both event-day and lead-time notifications.

### Rationale

- Gives users control over when reminders appear
- Avoids a fixed hardcoded schedule across all events

### Tradeoff

- Adds model and migration complexity

## 7. Persist Simple UI Preferences in Settings

### Decision

Persist dark mode and hide-completed behavior in the `settings` box.

### Rationale

- Settings are part of user experience, not transient session state
- Simple persistence keeps the app feeling consistent across launches

### Tradeoff

- Settings logic is currently presentation-driven and may need a dedicated module later

## Future Revisit Triggers

- Need for cloud sync or multi-device state
- Need for richer event recurrence
- Need for export/import or backup flows
- Performance issues with very large local event lists
