lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'models/bill.dart';
import 'models/payment.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'router.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.showDailyPendingNotification();
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(PaymentAdapter());
  await HiveService.initBoxes();

  // Primera ejecución: facturas de ejemplo
  await HiveService.createExampleBillsIfNeeded();

  // Notificaciones y WorkManager
  await NotificationService.initialize();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  // Tarea diaria a las 8:00 AM
  await Workmanager().registerPeriodicTask(
    'daily_pending',
    'showDailyPending',
    frequency: const Duration(days: 1),
    initialDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
