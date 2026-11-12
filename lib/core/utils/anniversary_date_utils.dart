/// Utility for normalized UTC date and duration calculations between partners.
class AnniversaryDateUtils {
  /// Calculates elapsed days together based on UTC calendar dates.
  ///
  /// Day 1 represents the start day itself.
  /// Using UTC calendar dates guarantees identical results across partner devices
  /// regardless of device local timezones or minor clock drift.
  static int calculateDaysTogether(
    DateTime startDate, {
    DateTime? serverTime,
  }) {
    final startUtc = startDate.toUtc();
    final startDay = DateTime.utc(startUtc.year, startUtc.month, startUtc.day);

    final currentUtc = (serverTime ?? DateTime.now()).toUtc();
    final today = DateTime.utc(currentUtc.year, currentUtc.month, currentUtc.day);

    final diffInDays = today.difference(startDay).inDays;
    // If today is the start date or after, Day 1 is the start day itself
    return diffInDays >= 0 ? diffInDays + 1 : 1;
  }

  /// Calculates days until a target milestone date from today in UTC calendar days.
  static int calculateDaysUntil(
    DateTime targetDate, {
    bool isRecurringAnnual = false,
    DateTime? serverTime,
  }) {
    final nowUtc = (serverTime ?? DateTime.now()).toUtc();
    final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    DateTime target = targetDate.toUtc();
    DateTime targetDay = DateTime.utc(today.year, target.month, target.day);

    if (isRecurringAnnual) {
      if (targetDay.isBefore(today)) {
        targetDay = DateTime.utc(today.year + 1, target.month, target.day);
      }
    } else {
      targetDay = DateTime.utc(target.year, target.month, target.day);
    }

    final diff = targetDay.difference(today).inDays;
    return diff >= 0 ? diff : 0;
  }
}
