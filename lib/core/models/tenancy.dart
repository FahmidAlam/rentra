class Tenancy {
  final int id;
  final String tenantId;
  final int unitId;
  final String tenantEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final bool active;

  Tenancy({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.tenantEmail,
    this.startDate,
    this.endDate,
    required this.status,
    required this.active,
  });


  factory Tenancy.fromJson(Map<String, dynamic> json) {
    return Tenancy(
      id: json['id'],
      unitId: json['unit_id'],
      tenantId: json['tenant_id'],
      tenantEmail: json['profiles']['email'],
      status: json['status'],
      active: json['active'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'])
          : null,
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'unit_id': unitId,
      'status': status,
      'active': active,
    };
  }
}