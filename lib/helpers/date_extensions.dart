import 'package:intl/intl.dart';

extension DateHelpers on DateTime {
  String toRelativeDateString() {
    final now = DateTime.now();
    
    // Normalize dates to remove time (set to midnight 00:00:00) 
    // This ensures we are only comparing calendar days!
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final taskDate = DateTime(year, month, day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      // If it's any other day, format it cleanly (e.g., "Jun 29, 2026")
      return DateFormat('yMMMd').format(this);
    }
  }
}