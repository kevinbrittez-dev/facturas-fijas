import 'dart:io';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "facturas_fijas.db");
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        dia_vencimiento INTEGER NOT NULL,
        ultimo_monto REAL NOT NULL,
        notas TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        monto_pagado REAL NOT NULL,
        fecha_pago_iso TEXT NOT NULL,
        FOREIGN KEY(invoice_id) REFERENCES invoices(id)
      );
    ''');
  }

  static Database get db {
    if (_db == null) {
      throw Exception('Base de datos no inicializada');
    }
    return _db!;
  }

  // Invoice CRUD
  static Future<int> insertInvoice(Invoice inv) async {
    return await db.insert('invoices', inv.toMap());
  }

  static Future<int> updateInvoice(Invoice inv) async {
    return await db.update('invoices', inv.toMap(), where: 'id = ?', whereArgs: [inv.id]);
  }

  static Future<int> deleteInvoice(int id) async {
    await db.delete('payments', where: 'invoice_id = ?', whereArgs: [id]);
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Invoice>> getAllInvoices() async {
    final res = await db.query('invoices', orderBy: 'nombre COLLATE NOCASE');
    return res.map((m) => Invoice.fromMap(m)).toList();
  }

  static Future<Invoice?> getInvoiceById(int id) async {
    final res = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    return Invoice.fromMap(res.first);
  }

  // Payments
  static Future<int> insertPayment(Payment p) async {
    return await db.insert('payments', p.toMap());
  }

  static Future<int> updatePayment(Payment p) async {
    return await db.update('payments', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  static Future<List<Payment>> getPaymentsForInvoice(int invoiceId, {int? limit}) async {
    final res = await db.query('payments',
        where: 'invoice_id = ?', whereArgs: [invoiceId], orderBy: 'year DESC, month DESC', limit: limit);
    return res.map((m) => Payment.fromMap(m)).toList();
  }

  static Future<Payment?> getPaymentForMonth(int invoiceId, int year, int month) async {
    final res = await db.query('payments',
        where: 'invoice_id = ? AND year = ? AND month = ?', whereArgs: [invoiceId, year, month]);
    if (res.isEmpty) return null;
    return Payment.fromMap(res.first);
  }

  static Future<List<Payment>> getPaymentsForYear(int year) async {
    final res = await db.query('payments', where: 'year = ?', whereArgs: [year], orderBy: 'month ASC');
    return res.map((m) => Payment.fromMap(m)).toList();
  }

  static Future<double> totalForMonth(int year, int month) async {
    final res = await db.rawQuery(
        'SELECT SUM(monto_pagado) as total FROM payments WHERE year = ? AND month = ?', [year, month]);
    final val = res.first['total'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  static Future<double> totalForYear(int year) async {
    final res = await db.rawQuery('SELECT SUM(monto_pagado) as total FROM payments WHERE year = ?', [year]);
    final val = res.first['total'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  static Future<List<Payment>> getAllPayments() async {
    final res = await db.query('payments', orderBy: 'year DESC, month DESC');
    return res.map((m) => Payment.fromMap(m)).toList();
  }
}
