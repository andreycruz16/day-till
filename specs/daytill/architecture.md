# DayTill Architecture

## Architecture Style

The app uses clean architecture with three layers:

- Presentation
- Domain
- Data

This keeps Flutter UI concerns separate from business rules and persistence details, while staying lightweight enough for a POC.

## Layer Breakdown

### Presentation

Responsibilities:

- Render screens and widgets
- Manage UI state
- Handle user interactions
- Observe Riverpod providers

Main elements:

- Screens: home, event form, event detail/settings if needed
- Controllers / notifiers: event list, form state, notification settings
- Providers for app-facing use cases

### Domain

Responsibilities:

- Define core entities
- Encapsulate countdown rules
- Expose use cases and repository contracts

Main elements:

- Entities: `Event`, `EventType`, `ReminderOption`
- Use cases: create event, update event, delete event, watch events, compute countdown
- Repository interfaces

### Data

Responsibilities:

- Persist data in Hive
- Map Hive models to domain entities
- Schedule/cancel local notifications

Main elements:

- Hive boxes and adapters
- Repository implementations
- Notification service using `flutter_local_notifications`

## Flutter-Specific Design

### State Management

- Riverpod is used for dependency injection and reactive state updates.
- `Notifier` or `AsyncNotifier` types manage event list and form workflows.
- Providers expose repositories and services to the UI layer.

### Persistence

- Hive is initialized during app startup before the main app shell loads.
- A single local box is sufficient for the POC, with room to split later if needed.

### Notifications

- Notification setup is encapsulated in a dedicated local service.
- Event persistence and notification scheduling are coordinated in the repository or an application service.
- Notification IDs should be deterministic to support update and cancel flows.

## High-Level Flow

1. User creates or edits an event from the form screen.
2. Presentation layer validates input and triggers a domain use case.
3. Domain layer calls repository interfaces.
4. Data layer writes to Hive and schedules or updates local notifications.
5. Riverpod providers emit updated state to the UI.

## Suggested Folder Structure

```text
lib/
  core/
    utils/
    services/
  features/
    events/
      presentation/
        screens/
        widgets/
        providers/
      domain/
        entities/
        repositories/
        usecases/
      data/
        models/
        datasources/
        repositories/
```

## Startup Sequence

1. Initialize Flutter bindings.
2. Initialize Hive and register adapters.
3. Initialize local notifications.
4. Load app providers.
5. Render the home screen.

## Risks

- Timezone edge cases may affect reminder timing.
- Notification reliability differs slightly across Android and iOS.
- Hive schema changes require careful migration planning.

## Future Enhancements

- Separate repositories for events and reminders if complexity grows.
- Background refresh hooks for date-based UI updates.
- App-level import/export service for local backups.
