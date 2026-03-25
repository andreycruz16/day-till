import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/presentation/providers/theme_mode_provider.dart';
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
    final hideCompleted = ref.watch(hideCompletedEventsProvider);
    final countdownService = ref.watch(countdownServiceProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    var filteredEvents = switch (filter) {
      EventListFilter.all => events,
      EventListFilter.birthdays =>
        events.where((event) => event.type == EventType.birthday).toList(),
      EventListFilter.events =>
        events.where((event) => event.type == EventType.general).toList(),
    };
    if (hideCompleted) {
      filteredEvents = filteredEvents.where((event) {
        return countdownService.daysRemaining(event, now) >= 0;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Till'),
        actions: [
          IconButton(
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: events.isEmpty
            ? const _EmptyState()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: EventListFilter.values.map((value) {
                            return ChoiceChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(_filterLabel(value)),
                              selected: filter == value,
                              onSelected: (_) {
                                ref
                                        .read(eventListFilterProvider.notifier)
                                        .state =
                                    value;
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  if (filteredEvents.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _FilteredEmptyState(
                        filter: filter,
                        hideCompleted: hideCompleted,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 92),
                      sliver: SliverList.separated(
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return EventCard(
                            event: event,
                            daysRemaining: countdownService.daysRemaining(
                              event,
                              now,
                            ),
                            activeCountdown: countdownService
                                .formatActiveCountdown(event, now),
                            nextOccurrence: countdownService.nextOccurrence(
                              event,
                              now,
                            ),
                            onTap: () => _openForm(context, event: event),
                            onDelete: () => _confirmDelete(context, ref, event),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
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

  Future<void> _openSettings(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
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
  const _FilteredEmptyState({
    required this.filter,
    required this.hideCompleted,
  });

  final EventListFilter filter;
  final bool hideCompleted;

  @override
  Widget build(BuildContext context) {
    final message = hideCompleted
        ? 'No matching upcoming events.'
        : switch (filter) {
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
