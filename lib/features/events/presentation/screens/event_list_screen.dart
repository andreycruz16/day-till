import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../providers/event_list_provider.dart';
import '../widgets/event_card.dart';
import 'event_form_screen.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider);
    final filter = ref.watch(eventListFilterProvider);
    final countdownService = ref.watch(countdownServiceProvider);
    final filteredEvents = switch (filter) {
      EventListFilter.all => events,
      EventListFilter.birthdays =>
        events.where((event) => event.type == EventType.birthday).toList(),
      EventListFilter.events =>
        events.where((event) => event.type == EventType.general).toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('DayTill')),
      body: SafeArea(
        child: events.isEmpty
            ? const _EmptyState()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EventListFilter.values.map((value) {
                          return ChoiceChip(
                            label: Text(_filterLabel(value)),
                            selected: filter == value,
                            onSelected: (_) {
                              ref.read(eventListFilterProvider.notifier).state =
                                  value;
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filteredEvents.isEmpty
                        ? _FilteredEmptyState(filter: filter)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: filteredEvents.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              final now = DateTime.now();
                              return EventCard(
                                event: event,
                                daysRemaining: countdownService.daysRemaining(
                                  event,
                                  now,
                                ),
                                nextOccurrence: countdownService.nextOccurrence(
                                  event,
                                  now,
                                ),
                                onTap: () => _openForm(context, event: event),
                                onDelete: () =>
                                    _confirmDelete(context, ref, event),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Event? event}) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventFormScreen(event: event)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event?'),
          content: Text('Remove "${event.title}" and its reminders?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await ref.read(eventListProvider.notifier).deleteEvent(event.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${event.title} deleted')));
      }
    }
  }

  String _filterLabel(EventListFilter filter) {
    return switch (filter) {
      EventListFilter.all => 'All',
      EventListFilter.birthdays => 'Birthdays',
      EventListFilter.events => 'Events',
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Track birthdays and important dates',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first countdown to get started.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.filter});

  final EventListFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      EventListFilter.all => 'No events yet.',
      EventListFilter.birthdays => 'No birthdays added yet.',
      EventListFilter.events => 'No general events added yet.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
