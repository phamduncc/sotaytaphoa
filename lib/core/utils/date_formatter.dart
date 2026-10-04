import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _dbFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dbDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String toDbDate(DateTime date) => _dbFormat.format(date);
  static String toDbDateTime(DateTime date) => _dbDateTimeFormat.format(date);
  static String todayDb() => _dbFormat.format(DateTime.now());
  static String nowDb() => _dbDateTimeFormat.format(DateTime.now());

  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      if (value.contains('/')) return _dateFormat.parse(value);
      return _dbFormat.parse(value);
    } catch (_) {
      return null;
    }
  }

  static DateTime? parseDbDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      if (value.length > 10) return _dbDateTimeFormat.parse(value);
      return _dbFormat.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String formatDbDate(String? dbDate) {
    if (dbDate == null || dbDate.isEmpty) return '';
    final dt = parseDbDate(dbDate);
    if (dt == null) return dbDate;
    return _dateFormat.format(dt);
  }

  static bool isExpiringSoon(String? expiryDate, {int warningDays = 30}) {
    if (expiryDate == null || expiryDate.isEmpty) return false;
    final dt = parseDate(expiryDate) ?? parseDbDate(expiryDate);
    if (dt == null) return false;
    final daysUntilExpiry = dt.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= warningDays;
  }

  static bool isExpired(String? expiryDate) {
    if (expiryDate == null || expiryDate.isEmpty) return false;
    final dt = parseDate(expiryDate) ?? parseDbDate(expiryDate);
    if (dt == null) return false;
    return dt.isBefore(DateTime.now());
  }

  static String getMonthStart(DateTime date) =>
      _dbFormat.format(DateTime(date.year, date.month, 1));

  static String getMonthEnd(DateTime date) =>
      _dbFormat.format(DateTime(date.year, date.month + 1, 0));

  static String getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    return _dbFormat.format(monday);
  }
}
