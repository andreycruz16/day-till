# DayTill UI Design

## UI Principles

- Keep the interface compact and readable.
- Make countdown information scannable first.
- Keep the event form simple even when handling birthday and reminder edge cases.
- Use settings for persistent UI preferences instead of overloading the home screen.

## Main Screens

### 1. Home / Countdown List

### Purpose

Show saved events and birthdays with countdown status.

### Content

- App bar with app name
- Settings action
- Filter chips: `All`, `Birthdays`, `Events`
- Scrollable list of event cards
- Floating action button to add an event

### Card Elements

- Event title
- Event type pill
- Optional reminder bell pill
- Date or birthday information
- Next birthday / next occurrence line
- Age text for birthdays when birth year is known
- Day-based countdown label
- Active countdown text
- Delete action

### Behavior Notes

- Cards are compact to fit more items on screen.
- The whole home content scrolls as one surface.
- The homepage respects the `Hide completed events` setting.

### 2. Add / Edit Event Screen

### Purpose

Create or update an event with minimal friction.

### Fields

- Title
- Event type
- Month / Day / Year date entry
- Optional birthday year toggle
- Notes
- Enable reminders toggle
- Reminder lead-time selector
- Reminder time selector

### Birthday-Specific Behavior

- Birthdays are labeled as `Date of birth`.
- Users can disable `I know the birth year`.
- If birth year is unknown, the year selector is hidden.

### Reminder Behavior

- Enabling reminders defaults the selection to `On event day`.
- `No reminder` is not shown as an enabled choice.
- Reminder time defaults to `6:00 AM`.

### 3. Settings Screen

### Purpose

Store persistent display and homepage behavior preferences.

### Current Options

- Dark mode
- Hide completed events

## Navigation

- Single-stack navigation
- Home -> add/edit event
- Home -> settings

## Accessibility

- Theme-aware chips and pills should remain readable in light and dark mode.
- Do not rely on color alone for event type or reminder state.
- Countdown text should remain readable at compact card sizes.

## Future Enhancements

- Search and sort controls
- Calendar-style overview
- More granular appearance settings
- Better empty-state illustrations or onboarding
