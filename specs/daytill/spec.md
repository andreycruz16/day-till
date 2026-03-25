# DayTill Software Design Document

## Overview

Day Till is an offline-first Flutter mobile app for tracking upcoming events and birthdays. Users can create personal countdown items, see live time remaining, and receive local reminders without any backend or account system.

The current implementation is still POC-sized, but it now includes more product polish than the initial draft: dark mode, homepage filtering, birthday age display, optional unknown birth year, configurable reminder lead time, and configurable reminder time.

## Goals

- Let users create, edit, and delete countdown items quickly.
- Show upcoming events and birthdays in a compact, readable list.
- Keep all data local to the device using Hive.
- Schedule local reminders with no server dependency.
- Keep the app simple enough to maintain as a solo or small-team Flutter project.

## Non-Goals

- User accounts or cloud sync
- Shared calendars or collaborative lists
- Backend APIs or remote notifications
- Complex recurring rules beyond birthday handling

## Core Use Cases

### Create Event

User creates a `general event` or `birthday`, fills in the required date fields, optionally enables reminders, and saves. The event is stored locally and notifications are scheduled if enabled.

### Track Countdown

User opens the home screen and sees a filtered list of saved items ordered by nearest upcoming date. Each card shows a day-based label plus an active countdown string.

### Manage Birthday Details

User can mark a birthday with or without a known birth year. If the year is known, the app also shows the next age to be reached.

### Manage Settings

User can enable dark mode and choose whether completed events should be hidden from the homepage.

## Current Feature Scope

- Create, edit, and delete events
- Event types: `birthday` and `general`
- Birthday countdown based on next yearly occurrence
- Optional unknown birth year for birthdays
- Birthday age display when birth year is known
- Local reminders with selectable lead time
- Reminder time selection, defaulting to `6:00 AM`
- Live countdown text updated on a shared timer
- Homepage filter chips: `All`, `Birthdays`, `Events`
- Settings for dark mode and hide completed events

## Success Criteria

- App launches and loads local data quickly on a typical mobile device.
- CRUD operations update the homepage immediately.
- Notifications schedule and cancel correctly for enabled reminders.
- Homepage remains usable with a modest personal dataset.
- All primary flows work fully offline.

## Constraints

- Flutter mobile-first app
- Offline-only architecture
- Local persistence via Hive
- State management via Riverpod
- Local reminders via `flutter_local_notifications`

## Future Enhancements

- Search and sort controls
- Better notification reliability UX and test notification action
- Backup/restore or export/import
- Calendar or agenda-style views
- Home screen widgets
