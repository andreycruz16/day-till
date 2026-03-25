# DayTill Design Decisions

## Decision Summary

- Flutter is used for a fast cross-platform mobile POC.
- Clean architecture is used, but kept intentionally lightweight.
- Hive, Riverpod, and local notifications are the core technical choices.
- Birthday recurrence is handled by domain rules instead of a recurrence engine.
- Countdown values are computed at runtime instead of stored.

## 1. Use Flutter for a Single Mobile Codebase

### Decision

Build the app in Flutter for Android and iOS from one codebase.

### Rationale

- Fast POC development
- Consistent UI across platforms
- Strong plugin ecosystem for Hive, Riverpod, and local notifications

### Tradeoff

- Some notification behavior remains platform-specific

## 2. Use Clean Architecture, Kept Lightweight

### Decision

Adopt presentation, domain, and data layers without adding excessive abstraction.

### Rationale

- Keeps business logic testable
- Makes local persistence and notification code easier to isolate
- Fits future growth without overengineering the POC

### Tradeoff

- Slightly more setup than a single-layer Flutter app

## 3. Use Hive for Local Storage

### Decision

Store events locally in Hive.

### Rationale

- Fast local reads and writes
- Good Flutter support
- Simple schema for a small personal dataset
- Works fully offline

### Tradeoff

- Manual schema evolution needs discipline

## 4. Use Riverpod for State Management

### Decision

Use Riverpod for dependency injection and reactive state.

### Rationale

- Clear provider-based architecture
- Good testability
- Scales from simple state to async workflows cleanly

### Tradeoff

- Requires provider discipline and naming consistency

## 5. Use Local Notifications Only

### Decision

Use `flutter_local_notifications` for on-device reminders.

### Rationale

- Matches offline-first requirement
- No backend cost or operational complexity
- Sufficient for event-day and pre-event reminders

### Tradeoff

- Notifications depend on OS permissions and platform scheduling limits

## 6. Treat Birthdays as Yearly Recurring by Rule, Not by Complex Recurrence Engine

### Decision

Store a single date and compute the next birthday occurrence in domain logic.

### Rationale

- Keeps data model simple
- Avoids unnecessary recurrence infrastructure
- Covers the main birthday use case

### Tradeoff

- Not extensible enough for advanced recurrence patterns without future redesign

## 7. Compute Countdown Values Instead of Persisting Them

### Decision

Derive `daysRemaining` and related fields at runtime.

### Rationale

- Prevents stale stored values
- Keeps persistence model minimal
- Ensures correctness after date changes

### Tradeoff

- Requires consistent date calculation logic across screens

## Future Revisit Triggers

- Need for cloud sync or multi-device support
- Large datasets that require stronger querying
- Support for recurring event patterns beyond birthdays
- Need for backup/export and restore workflows
