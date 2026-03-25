import 'package:flutter/material.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:facturas_fijas/screens/payment_screen.dart';
import 'package:facturas_fijas/screens/invoice_detail.dart';
import 'package:facturas_fijas/services/db_service.dart';

class InvoiceTile extends StatefulWidget {
  final Invoice invoice;
  const InvoiceTile({super.key, required this.invoice});

  @override
  State<InvoiceTile> createState() => _InvoiceTileState();
}

class _InvoiceTileState extends State<InvoiceTile> {
  bool paidThisMonth = false;
  double paidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPaid();
  }

  Future<void> _checkPaid() async {
    final now = DateTime.now();
    final p = await DBService.getPaymentForMonth(widget.invoice.id!, now.year, now.month);
    setState(() {
      paidThisMonth = p != null;
      paidAmount = p?.montoPagado ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final day = inv.diaVencimiento <= lastDay ? inv.diaVencimiento : lastDay;
    final due = DateTime(now.year, now.month, day);
    final diffDays = due.difference(now).inDays;
    final daysText = diffDays >= 0 ? '$diffDays días' : 'Vencida';

    return Card(
      child: ListTile(
        title: Text(inv.nombre),
        subtitle: Text('Vence: día ${inv.diaVencimiento} • Último: ${NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(inv.ultimoMonto)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(paidThisMonth ? Icons.check_circle : Icons.cancel, color: paidThisMonth ? Colors.green : Colors.red),
            const SizedBox(height: 4),
            Text(daysText),
          ],
        ),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: inv.id!)));
          await _checkPaid();
        },
        onLongPress: () async {
          // Abrir pantalla de pago
          await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(invoice: inv)));
          await _checkPaid();
        },
      ),
    );
  }
}
