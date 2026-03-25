import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/hive_service.dart';
import '../models/payment.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String paymentId;
  const PaymentScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late double _amount;
  DateTime _paidDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final payment = HiveService.paymentsBox.get(widget.paymentId)!;
    _amount = payment.amountPaid;
  }

  @override
  Widget build(BuildContext context) {
    final payment = HiveService.paymentsBox.get(widget.paymentId)!;
    final bill = HiveService.billsBox.get(payment.billId)!;

    return Scaffold(
      appBar: AppBar(title: Text('Pago ${bill.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Mes actual: ${DateUtils.getMonthName(payment.month)} ${payment.year}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _amount.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto pagado (Gs.)'),
              onChanged: (v) => _amount = double.tryParse(v) ?? _amount,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de pago'),
              subtitle: Text(DateUtils.formatShortDate(_paidDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _paidDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (date != null) setState(() => _paidDate = date);
              },
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(paymentsProvider.notifier).markPaid(widget.paymentId, _amount, _paidDate);
                if (mounted) context.pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Marcar como PAGADA'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
