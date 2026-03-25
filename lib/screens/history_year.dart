import 'package:flutter/material.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryYearScreen extends StatefulWidget {
  const HistoryYearScreen({super.key});

  @override
  State<HistoryYearScreen> createState() => _HistoryYearScreenState();
}

class _HistoryYearScreenState extends State<HistoryYearScreen> {
  int _year = DateTime.now().year;
  Map<int, double> totals = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final payments = await DBService.getPaymentsForYear(_year);
    final Map<int, double> map = {for (var i = 1; i <= 12; i++) i: 0.0};
    for (var p in payments) {
      map[p.month] = (map[p.month] ?? 0) + p.montoPagado;
    }
    setState(() => totals = map);
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (i) => i + 1);
    return Scaffold(
      appBar: AppBar(title: const Text('Historial anual')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Año:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _year,
                  items: List.generate(10, (i) => DateTime.now().year - i)
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _year = v);
                    _load();
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: months
                    .map((m) => ListTile(
                          title: Text(DateFormat.MMMM('es').format(DateTime(0, m))),
                          trailing: Text(NumberFormat.currency(locale: 'es_PY', symbol: 'Gs ').format(totals[m] ?? 0.0)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: months
                      .map((m) => BarChartGroupData(x: m, barRods: [
                            BarChartRodData(toY: (totals[m] ?? 0.0) / 1000000.0, color: Colors.teal)
                          ]))
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 1 || idx > 12) return const SizedBox.shrink();
                          return Text(idx.toString());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Gráfico: valores en millones (Gs) para visualización'),
          ],
        ),
      ),
    );
  }
}
