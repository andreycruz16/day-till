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

  DateTime countdownTarget(Event event, DateTime now) {
    final nextDate = nextOccurrence(event, now);
    final isToday =
        nextDate.year == now.year &&
        nextDate.month == now.month &&
        nextDate.day == now.day;

    if (isToday) {
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    return nextDate;
  }

  Duration timeRemaining(Event event, DateTime now) {
    final difference = countdownTarget(event, now).difference(now);
    if (difference.isNegative) {
      return Duration.zero;
    }
    return difference;
  }

  String formatActiveCountdown(Event event, DateTime now) {
    final duration = timeRemaining(event, now);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }
}
