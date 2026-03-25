# DayTill Software Design Document

## Overview

DayTill is a lightweight Flutter mobile app for tracking upcoming events and birthdays. Users can create personal events, see how many days remain until each event, and receive local notifications on the event date with an optional reminder before it occurs.

This project is a proof of concept (POC) focused on fast local performance, simple UX, and fully offline operation.

## Goals

- Let users create, edit, and delete countdown events.
- Show clear day-based countdowns for each event.
- Support two event types: `birthday` and `general`.
- Trigger local notifications without any backend dependency.
- Keep the app simple, responsive, and easy to maintain.

## Non-Goals

- User accounts or cloud sync.
- Shared calendars or collaboration features.
- Complex recurrence rules beyond birthday behavior.
- Push notifications or server-side scheduling.

## Users

- People tracking birthdays for friends and family.
- People tracking personal milestones, deadlines, or trips.
- Users who want a simple countdown app without sign-in.

## Core Use Cases

### Create Event

User enters a title, date, event type, and optional reminder preference. The app saves the event locally and schedules a notification if enabled.

### View Countdown

User opens the app and sees a list of saved events sorted by nearest upcoming date, each with remaining days.

### Edit Event

User updates event details. The app persists the changes and refreshes any scheduled local notifications.

### Delete Event

User removes an event. The app deletes the record and cancels any associated scheduled notifications.

## Success Criteria

- App launches to usable content in under 2 seconds on a typical mid-range device.
- All primary features work without network access.
- Event CRUD operations feel immediate.
- Notifications fire reliably on-device for supported platforms.

## Constraints

- Flutter mobile app only.
- Offline-first architecture.
- Local persistence via Hive.
- State management via Riverpod.
- Local reminders via `flutter_local_notifications`.

## Future Enhancements

- Search and filtering by event type.
- Home screen widgets.
- Theme customization.
- Import/export of local data.
- Optional yearly reminder enhancements for birthdays.
