import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../models/bill.dart';
import '../models/payment.dart';

final billsProvider = StateNotifierProvider<BillsNotifier, List<Bill>>((ref) {
  return BillsNotifier();
});

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>((ref) {
  return PaymentsNotifier();
});

final currentMonthTotalProvider = Provider<double>((ref) {
  return HiveService.getTotalThisMonth();
});

final currentYearTotalProvider = Provider<double>((ref) {
  return HiveService.getTotalThisYear();
});

class BillsNotifier extends StateNotifier<List<Bill>> {
  BillsNotifier() : super([]) {
    _loadBills();
  }

  void _loadBills() {
    state = HiveService.billsBox.values.toList();
  }

  Future<void> addBill(Bill bill) async {
    await HiveService.billsBox.put(bill.id, bill);
    await HiveService.ensureCurrentMonthPayment(bill);
    _loadBills();
  }

  Future<void> deleteBill(String id) async {
    await HiveService.billsBox.delete(id);
    // Eliminar pagos asociados
    final toDelete = HiveService.paymentsBox.values.where((p) => p.billId == id).map((p) => p.key).toList();
    for (final key in toDelete) {
      await HiveService.paymentsBox.delete(key);
    }
    _loadBills();
  }
}

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  PaymentsNotifier() : super([]) {
    _loadPayments();
  }

  void _loadPayments() {
    state = HiveService.paymentsBox.values.toList();
  }

  Future<void> markPaid(String paymentId, double amount, DateTime paidDate) async {
    await HiveService.markAsPaid(
      paymentId: paymentId,
      amount: amount,
      paidDate: paidDate,
    );
    _loadPayments();
  }
}
