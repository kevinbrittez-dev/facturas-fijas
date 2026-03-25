import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: iOS));
    // Schedule daily morning summary at 08:00 local
    await _scheduleDailySummary();
    // Schedule reminders for 3 days before due for all invoices for current month
    await _scheduleMonthlyReminders();
  }

  static Future<void> _scheduleDailySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    await _plugin.zonedSchedule(
      0,
      'Facturas pendientes',
      'Revisa las facturas pendientes del mes.',
      scheduled.isBefore(now) ? scheduled.add(const Duration(days: 1)) : scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('daily_channel', 'Resumen diario', importance: Importance.defaultImportance),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> _scheduleMonthlyReminders() async {
    final invoices = await DBService.getAllInvoices();
    final now = DateTime.now();
    for (var inv in invoices) {
      final dueDay = inv.diaVencimiento;
      // compute date for this month
      final year = now.year;
      final month = now.month;
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      final day = dueDay <= lastDayOfMonth ? dueDay : lastDayOfMonth;
      final dueDate = DateTime(year, month, day);
      final reminderDate = dueDate.subtract(const Duration(days: 3));
      if (reminderDate.isAfter(DateTime.now())) {
        final tzDate = tz.TZDateTime.from(reminderDate, tz.local);
        await _plugin.zonedSchedule(
          inv.id!, // unique id
          'Recordatorio: ${inv.nombre}',
          'Vence el ${DateFormat('d MMMM').format(dueDate)}. Revisa y marca como pagada si corresponde.',
          tzDate,
          const NotificationDetails(
            android: AndroidNotificationDetails('reminder_channel', 'Recordatorios', importance: Importance.high),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> showImmediate(String title, String body) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('immediate', 'Inmediato', importance: Importance.high),
      ),
    );
  }
}
