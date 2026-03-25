import 'package:hive/hive.dart';
part 'bill.g.dart';

@HiveType(typeId: 0)
class Bill extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int dueDay;

  @HiveField(3)
  double lastAmount;

  @HiveField(4)
  String? notes;

  Bill({
    required this.id,
    required this.name,
    required this.dueDay,
    required this.lastAmount,
    this.notes,
  });
}
