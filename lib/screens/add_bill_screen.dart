import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/bill.dart';
import '../providers/app_provider.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  const AddBillScreen({super.key});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  int _dueDay = 15;
  String? _notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva factura fija')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la factura'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monto del último mes (Gs.)'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _dueDay,
                      decoration: const InputDecoration(labelText: 'Día de vencimiento'),
                      items: List.generate(31, (i) => i + 1)
                          .map((d) => DropdownMenuItem(value: d, child: Text(d.toString())))
                          .toList(),
                      onChanged: (v) => setState(() => _dueDay = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                onChanged: (v) => _notes = v,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final bill = Bill(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      dueDay: _dueDay,
                      lastAmount: double.parse(_amountController.text),
                      notes: _notes,
                    );
                    ref.read(billsProvider.notifier).addBill(bill);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar factura'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
