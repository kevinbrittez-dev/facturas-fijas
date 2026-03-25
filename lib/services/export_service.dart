import 'dart:io';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class ExportService {
  static Future<String> _downloadsPath() async {
    // Try to get external storage directory; fallback to app documents
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        // On Android the external storage path may be like /storage/emulated/0/Android/data/...
        // We try to use Downloads folder
        final downloads = Directory('/storage/emulated/0/Download');
        if (await downloads.exists()) return downloads.path;
        return dir.path;
      }
    }
    final doc = await getApplicationDocumentsDirectory();
    return doc.path;
  }

  static Future<bool> _ensurePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  static Future<File> _createFile(String filename) async {
    final base = await _downloadsPath();
    final path = p.join(base, filename);
    return File(path);
  }

  static Future<String> exportCsv({int? year}) async {
    final ok = await _ensurePermission();
    if (!ok) throw Exception('Permiso de almacenamiento denegado');
    final invoices = await DBService.getAllInvoices();
    final payments = await DBService.getAllPayments();

    final rows = <List<dynamic>>[];
    rows.add(['Factura', 'ID factura', 'Año', 'Mes', 'Monto pagado', 'Fecha pago', 'Notas', 'Día vencimiento']);
    for (var pmt in payments) {
      if (year != null && pmt.year != year) continue;
      final inv = invoices.firstWhere((i) => i.id == pmt.invoiceId);
      rows.add([
        inv.nombre,
        inv.id,
        pmt.year,
        pmt.month,
        pmt.montoPagado,
        pmt.fechaPagoIso,
        inv.notas ?? '',
        inv.diaVencimiento
      ]);
    }

    final csvStr = const ListToCsvConverter().convert(rows);
    final fileName = year == null ? 'facturas_todos_los_anos.csv' : 'facturas_$year.csv';
    final file = await _createFile(fileName);
    await file.writeAsString(csvStr);
    return file.path;
  }

  static Future<String> exportExcel({int? year}) async {
    final ok = await _ensurePermission();
    if (!ok) throw Exception('Permiso de almacenamiento denegado');
    final invoices = await DBService.getAllInvoices();
    final payments = await DBService.getAllPayments();

    final excel = Excel.createExcel();
    final sheet = excel['Facturas'];

    sheet.appendRow([
      'Factura',
      'ID factura',
      'Año',
      'Mes',
      'Monto pagado',
      'Fecha pago',
      'Notas',
      'Día vencimiento'
    ]);

    for (var pmt in payments) {
      if (year != null && pmt.year != year) continue;
      final inv = invoices.firstWhere((i) => i.id == pmt.invoiceId);
      sheet.appendRow([
        inv.nombre,
        inv.id,
        pmt.year,
        pmt.month,
        pmt.montoPagado,
        pmt.fechaPagoIso,
        inv.notas ?? '',
        inv.diaVencimiento
      ]);
    }

    final fileName = year == null ? 'facturas_todos_los_anos.xlsx' : 'facturas_$year.xlsx';
    final file = await _createFile(fileName);
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Error generando Excel');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
