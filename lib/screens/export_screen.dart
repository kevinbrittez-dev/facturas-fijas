import 'package:flutter/material.dart';
import 'package:facturas_fijas/services/export_service.dart';
import 'package:intl/intl.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int? _selectedYear;
  bool _loading = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final years = List.generate(6, (i) => DateTime.now().year - i);
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int?>(
              value: _selectedYear,
              decoration: const InputDecoration(labelText: 'Elegir año (o Todos los años)'),
              items: [null, ...years].map((y) {
                final label = y == null ? 'Todos los años' : '$y';
                return DropdownMenuItem<int?>(value: y, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_download),
              label: const Text('Descargar CSV'),
              onPressed: _loading ? null : () async => _exportCsv(),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_download),
              label: const Text('Descargar Excel'),
              onPressed: _loading ? null : () async => _exportExcel(),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_status.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_status)),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() {
      _loading = true;
      _status = '';
    });
    try {
      final path = await ExportService.exportCsv(year: _selectedYear);
      setState(() => _status = 'CSV guardado en: $path');
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() {
      _loading = true;
      _status = '';
    });
    try {
      final path = await ExportService.exportExcel(year: _selectedYear);
      setState(() => _status = 'Excel guardado en: $path');
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }
}
