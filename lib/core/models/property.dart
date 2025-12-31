class Property {
  final int id;
  final String title;
  final String city;
  final String imageUrl;
  final String ownerId;

  Property({
    required this.id,
    required this.title,
    required this.city,
    required this.imageUrl,
    required this.ownerId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['title'] as String,
      city: (json['city'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
      ownerId: json['owner_id'] as String,
    );
  }
}
