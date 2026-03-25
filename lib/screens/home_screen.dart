import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../services/hive_service.dart';
import '../models/bill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final monthTotal = ref.watch(currentMonthTotalProvider);
    final yearTotal = ref.watch(currentYearTotalProvider);

    // Facturas que vencen pronto (no pagadas este mes)
    final now = DateTime.now();
    final dueSoon = <Map<String, dynamic>>[];
    for (final bill in bills) {
      final payment = HiveService.paymentsBox.values.firstWhere(
        (p) => p.billId == bill.id && p.year == now.year && p.month == now.month,
        orElse: () => Payment(id: '', billId: '', year: 0, month: 0),
      );
      if (payment.id.isEmpty || payment.isPaid) continue;

      final dueDate = DateUtils.getDueDate(now.year, now.month, bill.dueDay);
      final days = DateUtils.daysUntilDue(dueDate);
      if (days <= 10) {
        dueSoon.add({
          'bill': bill,
          'days': days,
          'dueDate': dueDate,
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Totales
            Row(
              children: [
                Expanded(
                  child: _TotalCard(
                    title: 'Este mes',
                    amount: monthTotal,
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TotalCard(
                    title: 'Este año',
                    amount: yearTotal,
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vencen pronto
            const Text('Vencen pronto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (dueSoon.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('¡Todo al día! 🎉')))
            else
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dueSoon.length,
                  itemBuilder: (context, i) {
                    final item = dueSoon[i];
                    final bill = item['bill'] as Bill;
                    final days = item['days'] as int;
                    return Card(
                      margin: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bill.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('$days días', style: TextStyle(fontSize: 28, color: days < 0 ? Colors.red : Colors.orange)),
                            Text('Vence ${DateUtils.formatShortDate(item['dueDate'])}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            const Text('Mis facturas fijas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, i) {
                  final bill = bills[i];
                  final currentPayment = HiveService.paymentsBox.values.firstWhere(
                    (p) => p.billId == bill.id && p.year == now.year && p.month == now.month,
                    orElse: () => Payment(id: '', billId: '', year: 0, month: 0, isPaid: false),
                  );
                  final isPaidThisMonth = currentPayment.isPaid;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPaidThisMonth ? Colors.green : Colors.orange,
                      child: Icon(isPaidThisMonth ? Icons.check : Icons.pending, color: Colors.white),
                    ),
                    title: Text(bill.name),
                    subtitle: Text('Vence el ${bill.dueDay} • Gs. ${bill.lastAmount.toStringAsFixed(0)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/bill-detail/${bill.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-bill'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva factura'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.push('/bills');
          if (i == 2) context.push('/history');
          if (i == 3) context.push('/export');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Facturas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Exportar'),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;

  const _TotalCard({required this.title, required this.amount, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14)),
            Text('Gs. ${amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
