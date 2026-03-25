import 'package:flutter/material.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:intl/intl.dart';
import 'package:facturas_fijas/screens/payment_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Invoice? invoice;
  List<Payment> history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inv = await DBService.getInvoiceById(widget.invoiceId);
    final hist = await DBService.getPaymentsForInvoice(widget.invoiceId, limit: 24);
    setState(() {
      invoice = inv;
      history = hist;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(invoice!.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Día de vencimiento'),
              subtitle: Text('${invoice!.diaVencimiento}'),
            ),
            ListTile(
              title: const Text('Último monto'),
              subtitle: Text(NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(invoice!.ultimoMonto)),
            ),
            if (invoice!.notas != null && invoice!.notas!.isNotEmpty)
              ListTile(title: const Text('Notas'), subtitle: Text(invoice!.notas!)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Registrar pago mes actual'),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(invoice: invoice!)));
                await _load();
              },
            ),
            const SizedBox(height: 16),
            const Text('Historial (últimos 24 meses)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('Sin historial'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, i) {
                        final p = history[i];
                        final fecha = DateTime.parse(p.fechaPagoIso);
                        return ListTile(
                          title: Text('${p.year}-${p.month.toString().padLeft(2, '0')}'),
                          subtitle: Text('Pagado: ${NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(p.montoPagado)}'),
                          trailing: Text(DateFormat('dd/MM/yyyy').format(fecha)),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
