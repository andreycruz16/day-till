import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../smart_add/domain/entities/event_draft.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/reminder_option.dart';
import '../providers/event_list_provider.dart';
import '../../../settings/presentation/providers/theme_mode_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event, this.initialDraft})
    : assert(event == null || initialDraft == null);

  final Event? event;
  final EventDraft? initialDraft;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  late EventType _selectedType;
  late ReminderOption _selectedReminder;
  late bool _notificationsEnabled;
  late bool _isBirthYearKnown;
  late TimeOfDay _selectedReminderTime;
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  bool _isSaving = false;
  String? _saveErrorMessage;

  bool get _isEditing => widget.event != null;
  DateTime get _selectedDate =>
      DateTime(_effectiveYear, _selectedMonth, _selectedDay);

  int get _effectiveYear => _isBirthdayWithoutYear ? 2000 : _selectedYear;
  bool get _isBirthdayWithoutYear =>
      _selectedType == EventType.birthday && !_isBirthYearKnown;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final draft = widget.initialDraft;
    final initialDate =
        event?.date ??
        draft?.date ??
        DateTime.now().add(const Duration(days: 1));
    _titleController = TextEditingController(
      text: event?.title ?? draft?.title ?? '',
    );
    _notesController = TextEditingController(
      text: event?.notes ?? draft?.notes ?? '',
    );
    _selectedType = event?.type ?? draft?.type ?? EventType.general;
    _notificationsEnabled =
        event?.notificationsEnabled ?? draft?.notificationsEnabled ?? false;
    final initialReminder =
        event?.reminder ??
        draft?.reminder ??
        (_notificationsEnabled ? ReminderOption.sameDay : ReminderOption.none);
    _selectedReminder =
        _notificationsEnabled && initialReminder == ReminderOption.none
        ? ReminderOption.sameDay
        : initialReminder;
    _selectedReminderTime = TimeOfDay(
      hour: event?.reminderHour ?? draft?.reminderHour ?? 6,
      minute: event?.reminderMinute ?? draft?.reminderMinute ?? 0,
    );
    _isBirthYearKnown =
        event?.isDateYearKnown ?? draft?.isDateYearKnown ?? true;
    _selectedDay = initialDate.day;
    _selectedMonth = initialDate.month;
    _selectedYear = initialDate.year;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Event' : 'Add Event')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (widget.initialDraft != null) ...[
                _DraftReviewCard(draft: widget.initialDraft!),
                const SizedBox(height: 16),
              ],
              if (_saveErrorMessage != null) ...[
                Text(
                  _saveErrorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Mom birthday, Flight to Cebu...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Event type'),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_eventTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedType = value;
                    _clampSelectedYear();
                    _clampSelectedDay();
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                _selectedType == EventType.birthday ? 'Date of birth' : 'Date',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_selectedType == EventType.birthday) ...[
                const SizedBox(height: 4),
                Text(
                  'Used to calculate the next birthday countdown',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I know the birth year'),
                  value: _isBirthYearKnown,
                  onChanged: (value) {
                    setState(() {
                      _isBirthYearKnown = value;
                      if (!value) {
                        _selectedYear = DateTime.now().year;
                      } else {
                        _clampSelectedYear();
                      }
                      _clampSelectedDay();
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: List.generate(12, (index) => index + 1).map((
                        month,
                      ) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                            DateFormat.MMMM().format(DateTime(2026, month)),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedMonth = value;
                          _clampSelectedDay();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedDay,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: _availableDays.map((day) {
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(day.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedDay = value);
                      },
                    ),
                  ),
                  if (!_isBirthdayWithoutYear) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _selectedType == EventType.birthday
                              ? 'Birth year'
                              : 'Year',
                        ),
                        items: _availableYears.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedYear = value;
                            _clampSelectedDay();
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selected: ${_selectedDateLabel()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable reminders'),
                subtitle: const Text('Get a local reminder on your device'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    if (value) {
                      if (_selectedReminder == ReminderOption.none) {
                        _selectedReminder = ReminderOption.sameDay;
                      }
                    } else {
                      _selectedReminder = ReminderOption.none;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderOption>(
                key: ValueKey(
                  '${_notificationsEnabled}_${_selectedReminder.name}',
                ),
                initialValue: _notificationsEnabled
                    ? (_selectedReminder == ReminderOption.none
                          ? ReminderOption.sameDay
                          : _selectedReminder)
                    : null,
                decoration: const InputDecoration(labelText: 'Reminder'),
                items: _availableReminderOptions.map((reminder) {
                  return DropdownMenuItem(
                    value: reminder,
                    child: Text(reminder.label),
                  );
                }).toList(),
                onChanged: _notificationsEnabled
                    ? (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedReminder = value);
                      }
                    : null,
              ),
              if (_notificationsEnabled) ...[
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder time'),
                  subtitle: Text(_formatReminderTime(context)),
                  trailing: const Icon(Icons.schedule_outlined),
                  onTap: _pickReminderTime,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reminder options include same day, 1 day, 3 days, 1 week, 2 weeks, and 1 month before.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int> get _availableDays {
    final lastDay = DateUtils.getDaysInMonth(_effectiveYear, _selectedMonth);
    return List<int>.generate(lastDay, (index) => index + 1);
  }

  List<int> get _availableYears {
    final currentYear = DateTime.now().year;
    final startYear = _selectedType == EventType.birthday
        ? 1900
        : currentYear - 5;
    final endYear = _selectedType == EventType.birthday ? currentYear : 2100;
    return [for (var year = endYear; year >= startYear; year--) year];
  }

  List<ReminderOption> get _availableReminderOptions {
    if (!_notificationsEnabled) {
      return const [];
    }
    return ReminderOption.values
        .where((option) => option != ReminderOption.none)
        .toList();
  }

  void _clampSelectedDay() {
    final maxDay = DateUtils.getDaysInMonth(_effectiveYear, _selectedMonth);
    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;
    }
  }

  void _clampSelectedYear() {
    final years = _availableYears;
    if (!years.contains(_selectedYear)) {
      _selectedYear = years.first;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveErrorMessage = null;
    });

    try {
      final reminder = _notificationsEnabled
          ? _selectedReminder
          : ReminderOption.none;

      await ref
          .read(eventListProvider.notifier)
          .saveEvent(
            title: _titleController.text,
            date: _selectedDate,
            type: _selectedType,
            reminder: reminder,
            notificationsEnabled: _notificationsEnabled,
            reminderHour: _selectedReminderTime.hour,
            reminderMinute: _selectedReminderTime.minute,
            isDateYearKnown: _selectedType == EventType.birthday
                ? _isBirthYearKnown
                : true,
            notes: _notesController.text,
            existing: widget.event,
          );

      if (!mounted) {
        return;
      }

      ref.read(eventListFilterProvider.notifier).state = EventListFilter.all;

      final hideCompleted = ref.read(hideCompletedEventsProvider);
      final daysRemaining = ref.read(
        countdownServiceProvider,
      ).daysRemaining(
        Event(
          id: widget.event?.id ?? 'preview',
          title: _titleController.text.trim(),
          date: _selectedDate,
          type: _selectedType,
          reminder: reminder,
          notificationsEnabled: _notificationsEnabled,
          createdAt: widget.event?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          reminderHour: _selectedReminderTime.hour,
          reminderMinute: _selectedReminderTime.minute,
          isDateYearKnown: _selectedType == EventType.birthday
              ? _isBirthYearKnown
              : true,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
        DateTime.now(),
      );

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            hideCompleted && daysRemaining < 0
                ? 'Event saved, but it is hidden because Hide completed events is on.'
                : _isEditing
                ? 'Event updated'
                : 'Event added: ${_titleController.text.trim()}',
          ),
        ),
      );

      if (widget.initialDraft != null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Navigator.of(context).pop();
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _saveErrorMessage = error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _eventTypeLabel(EventType type) {
    return switch (type) {
      EventType.birthday => 'Birthday',
      EventType.general => 'General event',
    };
  }

  String _selectedDateLabel() {
    if (_isBirthdayWithoutYear) {
      return DateFormat.MMMMd().format(
        DateTime(2000, _selectedMonth, _selectedDay),
      );
    }
    return DateFormat.yMMMMd().format(_selectedDate);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime,
    );

    if (picked != null) {
      setState(() => _selectedReminderTime = picked);
    }
  }

  String _formatReminderTime(BuildContext context) {
    final time = DateTime(
      2000,
      1,
      1,
      _selectedReminderTime.hour,
      _selectedReminderTime.minute,
    );
    return DateFormat.jm().format(time);
  }
}

class _DraftReviewCard extends StatelessWidget {
  const _DraftReviewCard({required this.draft});

  final EventDraft draft;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review your draft',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Add filled these fields for you. Double-check the details before saving.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (draft.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Things to review:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              for (final warning in draft.warnings) ...[
                Text('\u2022 $warning'),
                const SizedBox(height: 4),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
