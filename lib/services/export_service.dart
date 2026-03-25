import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'hive_service.dart';
import '../models/payment.dart';

class ExportService {
  static Future<String?> exportToExcel({int? year}) async {
    if (!(await _requestStoragePermission())) return null;

    final excel = Excel.createExcel();
    final now = DateTime.now();

    if (year == null) {
      // Todos los años
      final years = HiveService.paymentsBox.values.map((p) => p.year).toSet().toList()..sort();
      for (final y in years) {
        _addYearSheet(excel, y);
      }
    } else {
      _addYearSheet(excel, year);
    }

    final downloads = await getDownloadsDirectory();
    final fileName = year == null
        ? 'facturas_fijas_completo_${DateFormat('yyyyMMdd').format(now)}.xlsx'
        : 'facturas_fijas_$year.xlsx';

    final file = File('${downloads!.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }

  static Future<String?> exportToCsv({int? year}) async {
    if (!(await _requestStoragePermission())) return null;

    final buffer = StringBuffer();
    buffer.writeln('Factura,Mes,Año,Monto Pagado,Fecha Pago');

    final payments = year == null
        ? HiveService.paymentsBox.values.where((p) => p.isPaid)
        : HiveService.paymentsBox.values.where((p) => p.year == year && p.isPaid);

    for (final p in payments) {
      final bill = HiveService.billsBox.values.firstWhere((b) => b.id == p.billId);
      final date = p.paidDate != null ? DateFormat('dd/MM/yyyy').format(p.paidDate!) : '';
      buffer.writeln('${bill.name},${p.month},${p.year},${p.amountPaid},$date');
    }

    final downloads = await getDownloadsDirectory();
    final now = DateTime.now();
    final fileName = year == null
        ? 'facturas_fijas_completo_${DateFormat('yyyyMMdd').format(now)}.csv'
        : 'facturas_fijas_$year.csv';

    final file = File('${downloads!.path}/$fileName');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  static void _addYearSheet(Excel excel, int year) {
    final sheet = excel['$year'];
    sheet.appendRow(['Factura', 'Mes', 'Monto Pagado', 'Fecha Pago']);

    final payments = HiveService.paymentsBox.values
        .where((p) => p.year == year && p.isPaid)
        .toList();

    for (final p in payments) {
      final bill = HiveService.billsBox.values.firstWhere((b) => b.id == p.billId);
      sheet.appendRow([
        bill.name,
        DateUtils.getMonthName(p.month),
        p.amountPaid,
        p.paidDate != null ? DateFormat('dd/MM/yyyy').format(p.paidDate!) : ''
      ]);
    }
  }

  static Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return true;
  }
}
