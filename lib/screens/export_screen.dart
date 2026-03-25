import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/export_service.dart';
import '../core/constants.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar datos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Elige el período', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final path = await ExportService.exportToExcel();
                if (path != null) _showSuccess(context, path);
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Exportar TODO a Excel (.xlsx)'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final path = await ExportService.exportToCsv();
                if (path != null) _showSuccess(context, path);
              },
              icon: const Icon(Icons.description),
              label: const Text('Exportar TODO a CSV'),
            ),
            const Divider(height: 48),
            const Text('O selecciona un año específico'),
            const SizedBox(height: 12),
            DropdownButton<int>(
              hint: const Text('Seleccionar año'),
              items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
              onChanged: (year) async {
                if (year == null) return;
                final path = await ExportService.exportToExcel(year: year);
                if (path != null) _showSuccess(context, path);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Archivo guardado en Descargas:\n$path')),
    );
  }
}
