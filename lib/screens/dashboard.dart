import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:facturas_fijas/providers/invoice_provider.dart';
import 'package:facturas_fijas/screens/add_invoice.dart';
import 'package:facturas_fijas/screens/invoice_list.dart';
import 'package:facturas_fijas/widgets/invoice_tile.dart';
import 'package:intl/intl.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/screens/export_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas Fijas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Todas las facturas',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => prov.loadAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<double>(
                future: prov.totalMesActual(),
                builder: (context, snap) {
                  final totalMes = snap.data ?? 0.0;
                  return Card(
                    child: ListTile(
                      title: const Text('Total gastado este mes'),
                      subtitle: Text(NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(totalMes)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              FutureBuilder<double>(
                future: prov.totalAnoActual(),
                builder: (context, snap) {
                  final totalAno = snap.data ?? 0.0;
                  return Card(
                    child: ListTile(
                      title: const Text('Total gastado este año'),
                      subtitle: Text(NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(totalAno)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Vencen pronto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<Invoice>>(
                future: DBService.getAllInvoices(),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Text('No hay facturas registradas.');
                  }
                  final soon = _vencenPronto(list);
                  if (soon.isEmpty) return const Text('No hay facturas que venzan pronto.');
                  return Column(
                    children: soon.map((inv) => InvoiceTile(invoice: inv)).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar nueva factura'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInvoiceScreen()));
                    prov.loadAll();
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Accesos rápidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Historial anual'),
                onTap: () => Navigator.pushNamed(context, '/historial'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Invoice> _vencenPronto(List<Invoice> all) {
    final now = DateTime.now();
    final List<MapEntry<Invoice, int>> diffs = [];
    for (var inv in all) {
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      final day = inv.diaVencimiento <= lastDay ? inv.diaVencimiento : lastDay;
      final due = DateTime(now.year, now.month, day);
      final diff = due.difference(now).inDays;
      if (diff >= 0 && diff <= 7) {
        diffs.add(MapEntry(inv, diff));
      }
    }
    diffs.sort((a, b) => a.value.compareTo(b.value));
    return diffs.map((e) => e.key).toList();
  }
}
