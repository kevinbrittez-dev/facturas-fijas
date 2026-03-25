class AppConstants {
  static const String appName = 'Facturas Fijas';
  static const String boxBills = 'bills';
  static const String boxPayments = 'payments';
  static const String boxSettings = 'settings';
  static const String keyFirstLaunch = 'first_launch';

  // Ejemplos
  static const List<Map<String, dynamic>> exampleBills = [
    {
      'name': 'Luz ANDE',
      'dueDay': 10,
      'lastAmount': 65000.0,
      'notes': 'Consumo residencial',
    },
    {
      'name': 'Internet Tigo',
      'dueDay': 15,
      'lastAmount': 95000.0,
      'notes': 'Fibra 300 Mbps',
    },
    {
      'name': 'Alquiler',
      'dueDay': 5,
      'lastAmount': 2500000.0,
      'notes': 'Departamento centro',
    },
  ];
}
