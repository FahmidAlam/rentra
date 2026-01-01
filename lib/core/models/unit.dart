class Unit {
  final int id;
  final int propertyId;
  final String unitNumber;
  final double rent;
  final bool isAvailable;

  Unit({
    required this.id,
    required this.propertyId,
    required this.unitNumber,
    required this.rent,
    required this.isAvailable,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      unitNumber: json['unit_number'] as String,
      rent: (json['rent'] as num).toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }
}
