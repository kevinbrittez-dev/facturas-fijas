import 'package:shared_preferences/shared_preferences.dart';
import 'package:facturas_fijas/services/db_service.dart';
import 'package:facturas_fijas/models/invoice.dart';
import 'package:facturas_fijas/models/payment.dart';
import 'package:intl/intl.dart';

class SeedService {
  static const _seedKey = 'seed_done';

  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_seedKey) ?? false;
    if (done) return;

    // Crear 3 facturas de ejemplo: Luz, Internet, Alquiler
    final luz = Invoice(nombre: 'Luz ANDE', diaVencimiento: 10, ultimoMonto: 250000.0, notas: 'Ejemplo ANDE');
    final internet = Invoice(nombre: 'Internet Tigo', diaVencimiento: 5, ultimoMonto: 220000.0, notas: 'Fibra');
    final alquiler = Invoice(nombre: 'Alquiler', diaVencimiento: 1, ultimoMonto: 1500000.0, notas: 'Departamento');

    final luzId = await DBService.insertInvoice(luz);
    final internetId = await DBService.insertInvoice(internet);
    final alquilerId = await DBService.insertInvoice(alquiler);

    // Crear registros para el mes actual como pendientes (no pagados) - no insertamos pagos hasta que se pague.
    // Pero para mostrar historial, insertamos el pago del mes anterior con el ultimoMonto
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);
    final prevYear = prev.year;
    final prevMonth = prev.month;
    final iso = DateTime.now().toIso8601String();

    await DBService.insertPayment(Payment(
      invoiceId: luzId,
      year: prevYear,
      month: prevMonth,
      montoPagado: luz.ultimoMonto,
      fechaPagoIso: iso,
    ));

    await DBService.insertPayment(Payment(
      invoiceId: internetId,
      year: prevYear,
      month: prevMonth,
      montoPagado: internet.ultimoMonto,
      fechaPagoIso: iso,
    ));

    await DBService.insertPayment(Payment(
      invoiceId: alquilerId,
      year: prevYear,
      month: prevMonth,
      montoPagado: alquiler.ultimoMonto,
      fechaPagoIso: iso,
    ));

    await prefs.setBool(_seedKey, true);
  }
}
