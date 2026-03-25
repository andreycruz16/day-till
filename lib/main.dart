import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/notifications/local_notification_service.dart';
import 'features/events/data/models/event_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(EventTypeAdapter())
    ..registerAdapter(ReminderOptionAdapter())
    ..registerAdapter(EventModelAdapter());
  await Hive.openBox<EventModel>('events');

  final notifications = LocalNotificationService();
  await notifications.initialize();
  await notifications.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const DayTillApp(),
    ),
  );
}
