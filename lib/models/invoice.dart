import 'package:facturas_fijas/models/payment.dart';

class Invoice {
  int? id;
  String nombre;
  int diaVencimiento; // 1..31
  double ultimoMonto;
  String? notas;

  Invoice({
    this.id,
    required this.nombre,
    required this.diaVencimiento,
    required this.ultimoMonto,
    this.notas,
  });

  factory Invoice.fromMap(Map<String, dynamic> m) => Invoice(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        diaVencimiento: m['dia_vencimiento'] as int,
        ultimoMonto: (m['ultimo_monto'] as num).toDouble(),
        notas: m['notas'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'dia_vencimiento': diaVencimiento,
        'ultimo_monto': ultimoMonto,
        'notas': notas,
      };

  // Helper: get payments will be fetched separately
}
