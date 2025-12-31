// import 'package:rentra/Data/repositories/property_repository.dart';
// import 'package:rentra/core/models/property.dart';
// import 'package:rentra/core/supabase_client.dart';

// class PropertyController {
//   final PropertyRepository repository;

//   PropertyController(this.repository);

//   Future<List<Property>> fetchProperties() async {
//     try {
//       return await repository.getAllProperties();
//     } catch (e) {
//       throw Exception('Failed to fetch properties: $e');
//     }
//   }

//   Future<Property?> getPropertyById(int id) async {
//     return await repository.getPropertyById(id);
//   }

//   Future<void> addProperty({
//     required String title,
//     required String address,
//     required String city,
//     required String description,
//     required String coverImageUrl,
//     required List<String> galleryImages,
//   }) async {
//     final user = SupabaseManager.supabase.auth.currentUser;

//     if (user == null) {
//       throw Exception('User not authenticated');
//     }

//     await repository.addProperty(
//       ownerId: user.id,
//       title: title,
//       address: address,
//       city: city,
//       description: description,
//       coverImageUrl: coverImageUrl,
//       galleryImages: galleryImages,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:rentra/Data/repositories/property_repository.dart';
// import 'package:rentra/core/models/property.dart';
// import 'package:rentra/core/supabase_client.dart';

// class PropertyController extends ChangeNotifier {
//   final PropertyRepository repository;

//   PropertyController(this.repository);

//   bool isLoading = false;
//   List<Property> properties = [];

//   /// Fetch all properties
//   Future<void> fetchProperties() async {
//     try {
//       isLoading = true;
//       notifyListeners();

//       properties = await repository.getAllProperties();
//     } catch (e) {
//       debugPrint('Fetch properties error: $e');
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Get single property (detail screen use)
//   Future<Property?> getPropertyById(int id) {
//     return repository.getPropertyById(id);
//   }

//   /// Create property + images
//   Future<void> addProperty({
//     required String title,
//     required String address,
//     required String city,
//     required String description,
//     required String coverImageUrl,
//     required List<String> galleryImages,
//   }) async {
//     final user = SupabaseManager.supabase.auth.currentUser;
//     if (user == null) throw Exception('User not authenticated');

//     try {
//       isLoading = true;
//       notifyListeners();

//       await repository.addProperty(
//         ownerId: user.id,
//         title: title,
//         address: address,
//         city: city,
//         description: description,
//         coverImageUrl: coverImageUrl,
//         galleryImages: galleryImages,
//       );
//       List<Property> getMyProperties() {
//         final user = SupabaseManager.supabase.auth.currentUser;
//         if (user == null) return [];

//         return properties.where((p) => p.ownerId == user.id).toList();
//       }

//       // Auto refresh list
//       await fetchProperties();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:rentra/Data/repositories/property_repository.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/supabase_client.dart';

class PropertyController extends ChangeNotifier {
  final PropertyRepository repository;

  PropertyController(this.repository);

  // 🔐 Private state
  bool _isLoading = false;
  List<Property> _properties = [];

  // 📤 Public getters
  bool get isLoading => _isLoading;
  List<Property> get properties => _properties;

  /// 👤 Owner-specific properties
  List<Property> get myProperties {
    final user = SupabaseManager.supabase.auth.currentUser;
    if (user == null) return [];
    return _properties.where((p) => p.ownerId == user.id).toList();
  }

  /// 📥 Fetch all properties
  Future<void> fetchProperties() async {
    try {
      _isLoading = true;
      notifyListeners();

      _properties = await repository.getAllProperties();
    } catch (e) {
      debugPrint('Fetch properties error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔍 Single property (details screen)
  Future<Property?> getPropertyById(int id) {
    return repository.getPropertyById(id);
  }

  /// ➕ Create property
  Future<void> addProperty({
    required String title,
    required String address,
    required String city,
    required String description,
    required String coverImageUrl,
    required List<String> galleryImages,
  }) async {
    final user = SupabaseManager.supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      _isLoading = true;
      notifyListeners();

      await repository.addProperty(
        ownerId: user.id,
        title: title,
        address: address,
        city: city,
        description: description,
        coverImageUrl: coverImageUrl,
        galleryImages: galleryImages,
      );

      // 🔄 Refresh list after adding
      await fetchProperties();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
