import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facturas_fijas/screens/dashboard.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/services/notification_service.dart';
import 'package:facturas_fijas/services/seed_service.dart';
import 'package:facturas_fijas/providers/invoice_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.init();
  await NotificationService.init();
  await SeedService.seedIfNeeded();
  runApp(const FacturasApp());
}

class FacturasApp extends StatelessWidget {
  const FacturasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()..loadAll()),
      ],
      child: MaterialApp(
        title: 'Facturas Fijas',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
