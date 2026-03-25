import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/hive_service.dart';
import '../models/bill.dart';

class BillsListScreen extends ConsumerWidget {
  const BillsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todas mis facturas')),
      body: ListView.builder(
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          final now = DateTime.now();
          final payment = HiveService.paymentsBox.values.firstWhere(
            (p) => p.billId == bill.id && p.year == now.year && p.month == now.month,
            orElse: () => Payment(id: '', billId: '', year: 0, month: 0, isPaid: false),
          );

          return ListTile(
            title: Text(bill.name),
            subtitle: Text('Vence el ${bill.dueDay} • Último pago: Gs. ${bill.lastAmount.toStringAsFixed(0)}'),
            trailing: Chip(
              label: Text(payment.isPaid ? 'Pagada' : 'Pendiente'),
              backgroundColor: payment.isPaid ? Colors.green[100] : Colors.orange[100],
            ),
            onTap: () {
              if (!payment.isPaid) {
                context.push('/payment/${payment.id}');
              } else {
                context.push('/bill-detail/${bill.id}');
              }
            },
          );
        },
      ),
    );
  }
}
