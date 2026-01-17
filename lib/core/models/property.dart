class Property {
  final int id;
  final String title;
  final String city;
  final String imageUrl;
  final String ownerId;
  final String address;
  final String description;

  Property({
    required this.id,
    required this.title,
    required this.city,
    required this.imageUrl,
    required this.ownerId,
    required this.address,
    required this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['title'] as String,
      city: json['city'] ?? '',
      imageUrl: json['image_url'] ?? '',
      ownerId: json['owner_id'] as String,
      address: json['address'] ?? '',
      description: json['description'] ?? '',
    );
  }

  //ONLY fields that are allowed to change
  Property copyWith({
    String? title,
    String? city,
    String? address,
    String? description,
    String? imageUrl,
  }) {
    return Property(
      id: id,                 
      ownerId: ownerId,       
      title: title ?? this.title,
      city: city ?? this.city,
      address: address ?? this.address,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Used ONLY for update queries
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'city': city,
      'address': address,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
