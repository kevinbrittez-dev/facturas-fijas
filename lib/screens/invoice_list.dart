import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facturas_fijas/providers/invoice_provider.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/screens/add_invoice.dart';
import 'package:facturas_fijas/widgets/invoice_tile.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Todas las facturas')),
      body: FutureBuilder(
        future: prov.loadAll(),
        builder: (context, snap) {
          final list = prov.invoices;
          if (list.isEmpty) {
            return const Center(child: Text('No hay facturas. Agrega una con el botón +'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final inv = list[i];
              return InvoiceTile(invoice: inv);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInvoiceScreen()));
          prov.loadAll();
        },
      ),
    );
  }
}
