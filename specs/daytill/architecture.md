# DayTill Architecture

## Architecture Style

The app uses lightweight clean architecture with three layers:

- Presentation
- Domain
- Data

This keeps Flutter UI code separate from countdown and reminder rules while staying small enough for a POC/MVP codebase.

## Layer Breakdown

### Presentation

Responsibilities:

- Render screens and widgets
- Manage form state and filter state
- React to Riverpod providers
- Trigger save, delete, and settings updates

Current elements:

- `EventListScreen`
- `EventFormScreen`
- `SettingsScreen`
- `EventCard`
- Riverpod providers for event list, list filters, live clock, theme mode, and homepage settings

### Domain

Responsibilities:

- Define event entities and reminder options
- Encapsulate birthday recurrence rules
- Compute countdown and age-related derived values
- Expose repository contracts

Current elements:

- `Event`
- `EventType`
- `ReminderOption`
- `EventRepository`
- `CountdownService`

### Data

Responsibilities:

- Persist events and settings with Hive
- Convert between Hive models and domain entities
- Schedule and cancel local notifications

Current elements:

- `EventModel`
- `EventRepositoryHive`
- Hive `events` box
- Hive `settings` box
- `LocalNotificationService`

## Flutter-Specific Design

### Riverpod

- `StateNotifierProvider` is used for event list state and persisted settings state.
- `StreamProvider<DateTime>` supplies a shared clock tick for live countdown updates.
- Providers are also used for dependency injection of repositories and services.

### Hive

- `events` box stores countdown items.
- `settings` box stores UI preferences such as theme mode and hide completed events.
- Manual adapters are used instead of code generation to keep the project small.

### Notifications

- Notification scheduling is isolated in `LocalNotificationService`.
- Deterministic notification IDs support update and cancel flows.
- Scheduled times are based on the event’s configured reminder time, not a global fixed hour.

## High-Level Flow

1. App initializes Hive, registers adapters, opens boxes, and initializes local notifications.
2. Home screen reads events, settings, and the shared clock provider.
3. User creates or edits an event in the form screen.
4. Provider saves the domain entity through the repository.
5. Repository writes to Hive and schedules/cancels notifications as needed.
6. Home screen reflects changes immediately through Riverpod state updates.

## Current Folder Shape

```text
lib/
  app.dart
  main.dart
  core/
    notifications/
  features/
    events/
      data/
        models/
        repositories/
      domain/
        entities/
        repositories/
        services/
      presentation/
        providers/
        screens/
        widgets/
    settings/
      presentation/
        providers/
        screens/
```

## Startup Sequence

1. Initialize Flutter bindings.
2. Initialize Hive.
3. Register event-related adapters.
4. Open the `events` and `settings` boxes.
5. Initialize local notifications and request permissions.
6. Start the app with `ProviderScope`.

## Risks

- Hive field evolution needs careful backward-compatibility handling.
- Notification timing can vary by platform and OS policy.
- Live countdown refreshes must stay lightweight to avoid unnecessary rebuild cost.

## Future Enhancements

- Extract settings into a dedicated data/domain layer if settings grow beyond a few toggles.
- Add repository tests around migration cases for older Hive records.
- Add widget tests for settings-driven homepage behavior.
