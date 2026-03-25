enum ReminderOption {
  none(daysBefore: null, label: 'No reminder'),
  sameDay(daysBefore: 0, label: 'On event day'),
  oneDayBefore(daysBefore: 1, label: '1 day before'),
  threeDaysBefore(daysBefore: 3, label: '3 days before'),
  oneWeekBefore(daysBefore: 7, label: '1 week before'),
  twoWeeksBefore(daysBefore: 14, label: '2 weeks before'),
  oneMonthBefore(daysBefore: 30, label: '1 month before');

  const ReminderOption({required this.daysBefore, required this.label});

  final int? daysBefore;
  final String label;
}
