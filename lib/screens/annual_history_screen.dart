import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/hive_service.dart';
import '../core/utils.dart';

class AnnualHistoryScreen extends ConsumerStatefulWidget {
  const AnnualHistoryScreen({super.key});

  @override
  ConsumerState<AnnualHistoryScreen> createState() => _AnnualHistoryScreenState();
}

class _AnnualHistoryScreenState extends ConsumerState<AnnualHistoryScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final totals = HiveService.getMonthlyTotalsForYear(_selectedYear);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Anual'),
        actions: [
          DropdownButton<int>(
            value: _selectedYear,
            items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                .toList(),
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gráfico
          SizedBox(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(12, (i) {
                    final total = totals[i + 1] ?? 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: total / 1000, color: Colors.green)], // en miles
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(DateUtils.getMonthName(value.toInt() + 1).substring(0, 3)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, i) {
                final month = i + 1;
                final total = totals[month] ?? 0;
                return ListTile(
                  title: Text(DateUtils.getMonthName(month)),
                  trailing: Text('Gs. ${total.toStringAsFixed(0)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
