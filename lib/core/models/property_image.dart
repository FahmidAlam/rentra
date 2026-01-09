class PropertyImage {
  final int id;
  final int propertyId;
  final String imageUrl;
  final int position;
  final String caption; 

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.position,
    this.caption = '', 
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      imageUrl: json['image_url'] as String,
      position: json['position'] as int? ?? 0,
      caption: json['caption'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'image_url': imageUrl,
      'position': position,
      'caption': caption,
    };
  }

  // Copy with for updates
  PropertyImage copyWith({
    int? id,
    int? propertyId,
    String? imageUrl,
    int? position,
    String? caption,
  }) {
    return PropertyImage(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      imageUrl: imageUrl ?? this.imageUrl,
      position: position ?? this.position,
      caption: caption ?? this.caption,
    );
  }
}