import '../entities/event.dart';
import '../entities/event_type.dart';

class CountdownService {
  const CountdownService();

  DateTime nextOccurrence(Event event, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    if (event.type == EventType.general) {
      return eventDate;
    }

    var nextBirthday = DateTime(today.year, event.date.month, event.date.day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, event.date.month, event.date.day);
    }
    return nextBirthday;
  }

  int daysRemaining(Event event, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return nextOccurrence(event, now).difference(today).inDays;
  }
}
