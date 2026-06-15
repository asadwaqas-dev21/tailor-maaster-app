import "package:intl/intl.dart";

extension DateExtensions on DateTime {
  /// Format as "15 Jun 2026"
  String get formatted => DateFormat("dd MMM yyyy").format(toLocal());

  /// Format as "15 Jun 2026, 09:00 AM"
  String get formattedWithTime => DateFormat("dd MMM yyyy, hh:mm a").format(toLocal());

  /// Format as "15/06/2026"
  String get shortFormatted => DateFormat("dd/MM/yyyy").format(toLocal());

  /// Check if date is today
  bool get isToday {
    final local = toLocal();
    final now = DateTime.now();
    return local.year == now.year && local.month == now.month && local.day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final local = toLocal();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return local.year == tomorrow.year &&
        local.month == tomorrow.month &&
        local.day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => toLocal().isBefore(DateTime.now());

  /// Check if date is overdue (past and not today)
  bool get isOverdue => isPast && !isToday;

  /// Days remaining from today
  int get daysRemaining {
    final local = toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    return target.difference(today).inDays;
  }

  /// Relative time description
  String get relative {
    final days = daysRemaining;
    if (days == 0) return "Today";
    if (days == 1) return "Tomorrow";
    if (days == -1) return "Yesterday";
    if (days > 0) return "In $days days";
    return "${days.abs()} days ago";
  }
}
