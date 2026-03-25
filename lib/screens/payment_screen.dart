import 'package:flutter/material.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:provider/provider.dart';
import 'package:facturas_fijas/providers/invoice_provider.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final Invoice invoice;
  const PaymentScreen({super.key, required this.invoice});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _montoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  bool _pagado = true;

  @override
  void initState() {
    super.initState();
    _montoCtrl.text = widget.invoice.ultimoMonto.toInt().toString();
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoiceProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Pago - ${widget.invoice.nombre}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _montoCtrl,
              decoration: const InputDecoration(labelText: 'Monto a pagar (Gs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Fecha del pago'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es', 'ES'),
                  );
                  if (d != null) setState(() => _fecha = d);
                },
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _pagado,
              onChanged: (v) => setState(() => _pagado = v ?? true),
              title: const Text('Marcar como "Ya pagué"'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Guardar pago'),
              onPressed: () async {
                final monto = double.tryParse(_montoCtrl.text.trim()) ?? 0.0;
                if (_pagado) {
                  await prov.registerPayment(widget.invoice.id!, monto, _fecha);
                }
                if (mounted) Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
