import 'package:flutter/material.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:intl/intl.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> invoices = [];

  Future<void> loadAll() async {
    invoices = await DBService.getAllInvoices();
    notifyListeners();
  }

  Future<void> addInvoice(Invoice inv) async {
    await DBService.insertInvoice(inv);
    await loadAll();
  }

  Future<void> updateInvoice(Invoice inv) async {
    await DBService.updateInvoice(inv);
    await loadAll();
  }

  Future<void> deleteInvoice(int id) async {
    await DBService.deleteInvoice(id);
    await loadAll();
  }

  Future<Payment?> getPaymentForMonth(int invoiceId, int year, int month) async {
    return await DBService.getPaymentForMonth(invoiceId, year, month);
  }

  Future<void> registerPayment(int invoiceId, double monto, DateTime fecha) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final iso = fecha.toIso8601String();

    // Insert payment for current month
    final p = Payment(
      invoiceId: invoiceId,
      year: year,
      month: month,
      montoPagado: monto,
      fechaPagoIso: iso,
    );
    await DBService.insertPayment(p);

    // Update ultimo monto in invoice
    final inv = invoices.firstWhere((i) => i.id == invoiceId);
    inv.ultimoMonto = monto;
    await DBService.updateInvoice(inv);

    // Create next month record? We don't create a payment record for next month (it should be pending).
    // But to follow requirement "Crear automáticamente el registro para el siguiente mes (pendiente de pago)."
    // We'll not insert a payment row (that would mark as paid). Instead, we ensure UI treats missing payment as pendiente.
    // If desired, we could insert a placeholder with monto 0 and mark as unpaid; but payments table only stores paid entries.
    // So no extra DB insert is needed.

    await loadAll();
  }

  Future<double> totalMesActual() async {
    final now = DateTime.now();
    return await DBService.totalForMonth(now.year, now.month);
  }

  Future<double> totalAnoActual() async {
    final now = DateTime.now();
    return await DBService.totalForYear(now.year);
  }

  Future<List<Payment>> historyForInvoice(int invoiceId, {int months = 24}) async {
    final all = await DBService.getPaymentsForInvoice(invoiceId, limit: months);
    return all;
  }
}
