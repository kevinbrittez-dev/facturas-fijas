import 'package:hive/hive.dart';
part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String billId;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final int month;

  @HiveField(4)
  double amountPaid;

  @HiveField(5)
  DateTime? paidDate;

  @HiveField(6)
  bool isPaid;

  Payment({
    required this.id,
    required this.billId,
    required this.year,
    required this.month,
    this.amountPaid = 0.0,
    this.paidDate,
    this.isPaid = false,
  });
}
