class Reservation {
  final String id;
  final String spotName;
  final DateTime date;
  final String vehiclePlate;
  final String status;

  Reservation({
    required this.id,
    required this.spotName,
    required this.date,
    required this.vehiclePlate,
    required this.status,
  });
}
