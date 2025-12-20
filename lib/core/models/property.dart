class Property {
  final int id;
  final String title;
  final String city;
  final String imageUrl;

  Property({
    required this.id,
    required this.title,
    required this.city,
    required this.imageUrl,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['title'] as String,
      city: (json['city'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
    );
  }
}
