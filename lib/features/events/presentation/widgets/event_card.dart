import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.daysRemaining,
    required this.nextOccurrence,
    required this.onTap,
    required this.onDelete,
  });

  final Event event;
  final int daysRemaining;
  final DateTime nextOccurrence;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPast = daysRemaining < 0;
    final countdownLabel = switch (daysRemaining) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ when daysRemaining < 0 => '${daysRemaining.abs()} days ago',
      _ => '$daysRemaining days',
    };
    final primaryDateLabel = switch (event.type) {
      EventType.birthday =>
        'Date of birth: ${DateFormat.yMMMMd().format(event.date)}',
      EventType.general => DateFormat.yMMMMd().format(event.date),
    };
    final secondaryDateLabel = switch (event.type) {
      EventType.birthday =>
        'Next: ${DateFormat.yMMMMd().format(nextOccurrence)}',
      EventType.general when !isSameCalendarDate(event.date, nextOccurrence) =>
        'Next: ${DateFormat.yMMMMd().format(nextOccurrence)}',
      _ => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        _TypeChip(type: event.type),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      primaryDateLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (secondaryDateLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        secondaryDateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (event.notes case final notes?) ...[
                      const SizedBox(height: 8),
                      Text(
                        notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    countdownLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isPast
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isPast ? 'Completed' : 'Remaining',
                    style: Theme.of(context).textTheme.labelMedium,
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
    final (label, backgroundColor) = switch (type) {
      EventType.birthday => ('Birthday', const Color(0xFFF7D8B5)),
      EventType.general => ('Event', const Color(0xFFD5E8E3)),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}
