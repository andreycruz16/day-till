import 'package:hive/hive.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/reminder_option.dart';

class EventModel extends HiveObject {
  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.reminder,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final ReminderOption reminder;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  factory EventModel.fromDomain(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      date: event.date,
      type: event.type,
      reminder: event.reminder,
      notificationsEnabled: event.notificationsEnabled,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      notes: event.notes,
    );
  }

  Event toDomain() {
    return Event(
      id: id,
      title: title,
      date: date,
      type: type,
      reminder: reminder,
      notificationsEnabled: notificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
    );
  }
}

class EventTypeAdapter extends TypeAdapter<EventType> {
  @override
  final int typeId = 1;

  @override
  EventType read(BinaryReader reader) {
    return EventType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, EventType obj) {
    writer.writeByte(obj.index);
  }
}

class ReminderOptionAdapter extends TypeAdapter<ReminderOption> {
  @override
  final int typeId = 2;

  @override
  ReminderOption read(BinaryReader reader) {
    return ReminderOption.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ReminderOption obj) {
    writer.writeByte(obj.index);
  }
}

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (var index = 0; index < fieldCount; index++) {
      fields[reader.readByte()] = reader.read();
    }

    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as EventType,
      reminder: fields[4] as ReminderOption,
      notificationsEnabled: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.reminder)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.notes);
  }
}
