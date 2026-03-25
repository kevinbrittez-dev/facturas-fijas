import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/bill.dart';
import '../models/payment.dart';
import '../core/utils.dart';

class HiveService {
  static late Box<Bill> billsBox;
  static late Box<Payment> paymentsBox;

  static Future<void> initBoxes() async {
    billsBox = await Hive.openBox<Bill>(AppConstants.boxBills);
    paymentsBox = await Hive.openBox<Payment>(AppConstants.boxPayments);
  }

  static Future<void> createExampleBillsIfNeeded() async {
    if (billsBox.isEmpty) {
      final uuid = const Uuid();
      for (final example in AppConstants.exampleBills) {
        final bill = Bill(
          id: uuid.v4(),
          name: example['name'],
          dueDay: example['dueDay'],
          lastAmount: example['lastAmount'],
          notes: example['notes'],
        );
        await billsBox.put(bill.id, bill);

        // Crear pago pendiente para el mes actual
        final now = DateTime.now();
        final payment = Payment(
          id: uuid.v4(),
          billId: bill.id,
          year: now.year,
          month: now.month,
          amountPaid: bill.lastAmount,
          isPaid: false,
        );
        await paymentsBox.put(payment.id, payment);
      }
    }
  }

  // Crear o asegurar pago para mes actual
  static Future<Payment> ensureCurrentMonthPayment(Bill bill) async {
    final now = DateTime.now();
    final key = '${bill.id}_${now.year}_${now.month}';

    // Buscar pago existente
    final existing = paymentsBox.values.firstWhere(
      (p) => p.billId == bill.id && p.year == now.year && p.month == now.month,
      orElse: () => Payment(
        id: '',
        billId: '',
        year: 0,
        month: 0,
      ),
    );

    if (existing.id.isNotEmpty) return existing;

    // Crear nuevo pendiente
    final uuid = const Uuid();
    final payment = Payment(
      id: uuid.v4(),
      billId: bill.id,
      year: now.year,
      month: now.month,
      amountPaid: bill.lastAmount,
      isPaid: false,
    );
    await paymentsBox.put(payment.id, payment);
    return payment;
  }

  static Future<void> markAsPaid({
    required String paymentId,
    required double amount,
    required DateTime paidDate,
  }) async {
    final payment = paymentsBox.get(paymentId);
    if (payment == null) return;

    payment.amountPaid = amount;
    payment.paidDate = paidDate;
    payment.isPaid = true;
    await payment.save();

    // Actualizar último monto de la factura
    final bill = billsBox.get(payment.billId);
    if (bill != null) {
      bill.lastAmount = amount;
      await bill.save();
    }

    // Crear automáticamente el siguiente mes pendiente
    final nextMonth = payment.month == 12 ? 1 : payment.month + 1;
    final nextYear = payment.month == 12 ? payment.year + 1 : payment.year;

    final nextPayment = Payment(
      id: const Uuid().v4(),
      billId: payment.billId,
      year: nextYear,
      month: nextMonth,
      amountPaid: bill?.lastAmount ?? amount,
      isPaid: false,
    );
    await paymentsBox.put(nextPayment.id, nextPayment);
  }

  static List<Payment> getHistory(String billId, {int months = 24}) {
    final now = DateTime.now();
    final cutoffYear = now.year;
    final cutoffMonth = now.month - months;
    int cutoffY = cutoffYear;
    int cutoffM = cutoffMonth;
    if (cutoffM <= 0) {
      cutoffY--;
      cutoffM += 12;
    }

    return paymentsBox.values
        .where((p) =>
            p.billId == billId &&
            (p.year > cutoffY ||
                (p.year == cutoffY && p.month >= cutoffM)))
        .toList()
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });
  }

  static double getTotalThisMonth() {
    final now = DateTime.now();
    return paymentsBox.values
        .where((p) =>
            p.year == now.year &&
            p.month == now.month &&
            p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amountPaid);
  }

  static double getTotalThisYear() {
    final now = DateTime.now();
    return paymentsBox.values
        .where((p) => p.year == now.year && p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amountPaid);
  }

  static Map<int, double> getMonthlyTotalsForYear(int year) {
    final map = <int, double>{};
    for (int m = 1; m <= 12; m++) {
      map[m] = paymentsBox.values
          .where((p) => p.year == year && p.month == m && p.isPaid)
          .fold(0.0, (sum, p) => sum + p.amountPaid);
    }
    return map;
  }
}
