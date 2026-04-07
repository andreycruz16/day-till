import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/reminder_option.dart';
import '../../domain/entities/event_type.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.nextOccurrence,
    required this.onTap,
    required this.onDelete,
  });

  final Event event;
  final DateTime nextOccurrence;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextAge = event.ageOnNextOccurrence();
    final primaryDateLabel = switch (event.type) {
      EventType.birthday =>
        event.isDateYearKnown
            ? 'Date of birth: ${DateFormat.yMMMMd().format(event.date)}'
            : 'Birthday: ${DateFormat.MMMMd().format(event.date)}',
      EventType.general => DateFormat.yMMMMd().format(event.date),
    };
    final secondaryDateLabel = switch (event.type) {
      EventType.birthday =>
        event.isDateYearKnown
            ? 'Next: ${DateFormat.yMMMMd().format(nextOccurrence)}${nextAge == null ? '' : ' • Turns $nextAge'}'
            : 'Next: ${DateFormat.MMMMd().format(nextOccurrence)}',
      EventType.general when !isSameCalendarDate(event.date, nextOccurrence) =>
        'Next: ${DateFormat.yMMMMd().format(nextOccurrence)}',
      _ => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _TypeChip(type: event.type),
                        if (event.notificationsEnabled &&
                            event.reminder != ReminderOption.none)
                          _ReminderChip(reminderLabel: event.reminder.label),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primaryDateLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (secondaryDateLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondaryDateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (event.notes case final notes?) ...[
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool isSameCalendarDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final EventType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, backgroundColor, foregroundColor) = switch (type) {
      EventType.birthday => (
        'Birthday',
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      EventType.general => (
        'Event',
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({required this.reminderLabel});

  final String reminderLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              reminderLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
