import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../services/hive_service.dart';
import '../core/utils.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);

    // Canal
    const androidChannel = AndroidNotificationChannel(
      'facturas_channel',
      'Facturas Fijas',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> scheduleThreeDaysBefore(Bill bill, Payment payment) async {
    final dueDate = DateUtils.getDueDate(payment.year, payment.month, bill.dueDay);
    final reminderDate = dueDate.subtract(const Duration(days: 3));

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      payment.id.hashCode,
      '¡Recordatorio de factura!',
      '${bill.name} vence en 3 días (${DateUtils.formatShortDate(dueDate)})',
      TZDateTime.from(reminderDate, local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'facturas_channel',
          'Facturas Fijas',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showDailyPendingNotification() async {
    final now = DateTime.now();
    final unpaid = HiveService.paymentsBox.values.where((p) =>
        p.year == now.year &&
        p.month == now.month &&
        !p.isPaid);

    if (unpaid.isEmpty) return;

    final count = unpaid.length;
    final names = unpaid.map((p) {
      final bill = HiveService.billsBox.values.firstWhere((b) => b.id == p.billId);
      return bill.name;
    }).join(', ');

    await _notifications.show(
      999,
      'Facturas pendientes hoy',
      '$count factura(s) pendientes: $names',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'facturas_channel',
          'Facturas Fijas',
          importance: Importance.high,
        ),
      ),
    );
  }
}
