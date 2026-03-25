import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facturas_fijas/providers/invoice_provider.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  int _dia = 1;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _montoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoiceProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar factura')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _dia,
                      decoration: const InputDecoration(labelText: 'Día de vencimiento'),
                      items: List.generate(31, (i) => i + 1)
                          .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                          .toList(),
                      onChanged: (v) => setState(() => _dia = v ?? 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _montoCtrl,
                      decoration: const InputDecoration(labelText: 'Monto último mes (Gs)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese monto' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final inv = Invoice(
                    nombre: _nombreCtrl.text.trim(),
                    diaVencimiento: _dia,
                    ultimoMonto: double.tryParse(_montoCtrl.text.trim())?.toDouble() ?? 0.0,
                    notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
                  );
                  await prov.addInvoice(inv);
                  if (mounted) Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
