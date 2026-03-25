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

  late DateTime _selectedDate;
  late EventType _selectedType;
  late ReminderOption _selectedReminder;
  late bool _notificationsEnabled;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _notesController = TextEditingController(text: event?.notes ?? '');
    _selectedDate = event?.date ?? DateTime.now().add(const Duration(days: 1));
    _selectedType = event?.type ?? EventType.general;
    _selectedReminder = event?.reminder ?? ReminderOption.none;
    _notificationsEnabled = event?.notificationsEnabled ?? false;
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
                  setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat.yMMMMd().format(_selectedDate)),
                      const Icon(Icons.calendar_today_rounded),
                    ],
                  ),
                ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
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
