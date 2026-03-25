import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/reminder_option.dart';
import '../providers/event_list_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event});

  final Event? event;

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
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;
  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final initialDate =
        event?.date ?? DateTime.now().add(const Duration(days: 1));
    _titleController = TextEditingController(text: event?.title ?? '');
    _notesController = TextEditingController(text: event?.notes ?? '');
    _selectedType = event?.type ?? EventType.general;
    _selectedReminder = event?.reminder ?? ReminderOption.none;
    _notificationsEnabled = event?.notificationsEnabled ?? false;
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
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedDay,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedMonth,
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
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _selectedYear,
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
              const SizedBox(height: 8),
              Text(
                'Selected: ${DateFormat.yMMMMd().format(_selectedDate)}',
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
                    if (!value) {
                      _selectedReminder = ReminderOption.none;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderOption>(
                initialValue: _selectedReminder,
                decoration: const InputDecoration(labelText: 'Reminder'),
                items: ReminderOption.values.map((reminder) {
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
    final lastDay = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
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

  void _clampSelectedDay() {
    final maxDay = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
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

    setState(() => _isSaving = true);
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
          notes: _notesController.text,
          existing: widget.event,
        );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  String _eventTypeLabel(EventType type) {
    return switch (type) {
      EventType.birthday => 'Birthday',
      EventType.general => 'General event',
    };
  }
}
