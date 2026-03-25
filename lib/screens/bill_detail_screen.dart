import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../models/bill.dart';
import '../core/utils.dart';

class BillDetailScreen extends ConsumerWidget {
  final String billId;
  const BillDetailScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bill = HiveService.billsBox.get(billId)!;
    final history = HiveService.getHistory(billId);

    return Scaffold(
      appBar: AppBar(title: Text(bill.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Día de vencimiento: ${bill.dueDay}', style: const TextStyle(fontSize: 18)),
                if (bill.notes != null) ...[
                  const SizedBox(height: 8),
                  Text('Notas: ${bill.notes}'),
                ],
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Historial últimos 24 meses', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, i) {
                final p = history[i];
                return ListTile(
                  title: Text('${DateUtils.getMonthName(p.month)} ${p.year}'),
                  subtitle: Text('Pagado: Gs. ${p.amountPaid.toStringAsFixed(0)}'),
                  trailing: Text(p.paidDate != null ? DateUtils.formatShortDate(p.paidDate!) : 'Pendiente'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
