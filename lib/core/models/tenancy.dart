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
    print('📝 Parsing Tenancy from JSON: $json');
    
    try {
      //?Handle both nested and flattened data structures
      
      // Try to get email from nested profiles object first
      String tenantEmail = 'Unknown';
      if (json.containsKey('profiles') && json['profiles'] != null) {
        final profiles = json['profiles'] as Map<String, dynamic>;
        tenantEmail = profiles['email'] as String? ?? 'Unknown';
      }
      // If no profiles, use a fallback or the tenantId
      if (tenantEmail == 'Unknown' && json.containsKey('tenant_id')) {
        tenantEmail = '${(json['tenant_id'] as String).substring(0, 8)}...';
      }

      // Parse dates safely
      DateTime? startDate;
      DateTime? endDate;
      
      if (json['start_date'] != null) {
        try {
          startDate = DateTime.parse(json['start_date'] as String);
        } catch (e) {
          print('⚠️ Could not parse start_date: ${json['start_date']}');
        }
      }
      
      if (json['end_date'] != null) {
        try {
          endDate = DateTime.parse(json['end_date'] as String);
        } catch (e) {
          print('⚠️ Could not parse end_date: ${json['end_date']}');
        }
      }

      final tenancy = Tenancy(
        id: json['id'] as int,
        unitId: json['unit_id'] as int,
        tenantId: json['tenant_id'] as String,
        tenantEmail: tenantEmail,
        status: json['status'] as String? ?? 'pending',
        active: json['active'] as bool? ?? false,
        startDate: startDate,
        endDate: endDate,
      );
      
      print('✅ Successfully parsed Tenancy: id=${tenancy.id}, unit=${tenancy.unitId}');
      return tenancy;
    } catch (e) {
      print('❌ Error parsing Tenancy: $e, json: $json');
      rethrow;
    }
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