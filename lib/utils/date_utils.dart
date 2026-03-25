// Pequeñas utilidades de fecha si se necesitan en el futuro.
int daysUntil(DateTime target) {
  final now = DateTime.now();
  return target.difference(now).inDays;
}
