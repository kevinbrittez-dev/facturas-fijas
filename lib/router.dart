import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/bills_list_screen.dart';
import 'screens/add_bill_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/bill_detail_screen.dart';
import 'screens/annual_history_screen.dart';
import 'screens/export_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/bills', builder: (context, state) => const BillsListScreen()),
    GoRoute(path: '/add-bill', builder: (context, state) => const AddBillScreen()),
    GoRoute(
      path: '/payment/:paymentId',
      builder: (context, state) => PaymentScreen(paymentId: state.pathParameters['paymentId']!),
    ),
    GoRoute(
      path: '/bill-detail/:billId',
      builder: (context, state) => BillDetailScreen(billId: state.pathParameters['billId']!),
    ),
    GoRoute(path: '/history', builder: (context, state) => const AnnualHistoryScreen()),
    GoRoute(path: '/export', builder: (context, state) => const ExportScreen()),
  ],
);
