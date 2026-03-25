class Payment {
  int? id;
  int invoiceId;
  int year;
  int month; // 1..12
  double montoPagado;
  String fechaPagoIso; // ISO string

  Payment({
    this.id,
    required this.invoiceId,
    required this.year,
    required this.month,
    required this.montoPagado,
    required this.fechaPagoIso,
  });

  factory Payment.fromMap(Map<String, dynamic> m) => Payment(
        id: m['id'] as int?,
        invoiceId: m['invoice_id'] as int,
        year: m['year'] as int,
        month: m['month'] as int,
        montoPagado: (m['monto_pagado'] as num).toDouble(),
        fechaPagoIso: m['fecha_pago_iso'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoice_id': invoiceId,
        'year': year,
        'month': month,
        'monto_pagado': montoPagado,
        'fecha_pago_iso': fechaPagoIso,
      };
}
