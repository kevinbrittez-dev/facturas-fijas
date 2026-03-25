import 'package:intl/intl.dart';

class DateUtils {
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'es_ES').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  static String getMonthName(int month) {
    return DateFormat('MMMM', 'es_ES').format(DateTime(2024, month));
  }

  static DateTime getDueDate(int year, int month, int dueDay) {
    // Evita errores en meses con menos días (ej. 31 en febrero)
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dueDay > lastDay ? lastDay : dueDay);
  }

  static int daysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.difference(today).inDays;
  }

  static bool isOverdue(DateTime dueDate) {
    return daysUntilDue(dueDate) < 0;
  }
}
