# DayTill UI Design

## UI Principles

- Keep the interface minimal and calm.
- Prioritize countdown visibility over secondary metadata.
- Make adding and editing events quick.
- Keep the app understandable for first-time users.

## Main Screens

### 1. Home / Countdown List

### Purpose

Show all saved events and their countdowns.

### Content

- App bar with app name
- Primary action button to add an event
- Scrollable list of countdown cards
- Empty state when no events exist

### Card Elements

- Event title
- Event type badge
- Event date
- Days remaining
- Optional reminder indicator

### Interactions

- Tap card to edit or view details
- Swipe or menu action to delete
- Pull-to-refresh is optional, not required for a local-only app

### 2. Add / Edit Event Screen

### Purpose

Create a new event or update an existing one.

### Fields

- Title
- Date picker
- Event type selector
- Notes
- Notifications toggle
- Reminder option selector

### Actions

- Save
- Cancel / back
- Delete when editing an existing event

### Validation

- Title required
- Date required
- Reminder options disabled when notifications are off

### 3. Empty State

### Purpose

Guide first-time users when no events exist.

### Content

- Short explanation of what the app does
- CTA button: `Create your first event`

## Navigation

- Single-stack navigation is sufficient for the POC.
- Bottom navigation is not needed.
- Main flow: home -> add/edit -> home.

## UI Behavior Notes

- Countdown value should be visually prominent.
- Birthdays should be clearly labeled as recurring.
- Past general events can be styled differently from upcoming events.
- Save actions should provide immediate visual confirmation by returning to the updated list.

## Suggested Widgets

- `Scaffold`
- `ListView`
- `Card` or custom list tile
- `FloatingActionButton`
- `TextFormField`
- `DropdownButtonFormField` or segmented control
- `SwitchListTile`
- `showDatePicker`

## Accessibility

- Use readable text sizes and sufficient contrast.
- Do not rely on color alone to distinguish event types.
- Ensure tap targets are comfortable on mobile screens.

## Future Enhancements

- Calendar view
- Filter chips for birthdays vs general events
- Theme personalization
- Widget support for the next upcoming event
