class UserProfile {
  final String id;
  final String email;
  final String role;
  final String? fullName;  
  final String? phone;     // 
  final DateTime? createdAt; 
  
  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.createdAt,
  });
  
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'full_name': fullName,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  // Helper method to get display name
  String get displayName => fullName ?? email.split('@').first;
  
  // Helper to check if profile is complete
  bool get isComplete => fullName != null && phone != null;
}