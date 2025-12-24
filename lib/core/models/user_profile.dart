class UserProfile {
  final String id;
  final String role;

  UserProfile({required this.id, required this.role});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      role: map['role'],
    );
  }
}
