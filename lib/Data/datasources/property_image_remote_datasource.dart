import 'package:rentra/core/models/property_image.dart';
import 'package:rentra/core/supabase_client.dart';

abstract class IPropertyImageRemoteDataSource {
  Future<List<PropertyImage>> fetchImagesByProperty(int propertyId);
  Future<PropertyImage> uploadImage({
    required int propertyId,
    required String imageUrl,
    required String caption,
    required int position,
  });
  Future<void> deleteImage(int imageId);
  Future<void> updateImageCaption(int imageId, String caption);
  Future<void> updateImagePosition(int imageId, int position);
  Future<void> reorderImages(List<PropertyImage> images);
}

class PropertyImageRemoteDataSource implements IPropertyImageRemoteDataSource {
  @override
  Future<List<PropertyImage>> fetchImagesByProperty(int propertyId) async {
    try {
      final response = await SupabaseManager.supabase
          .from('property_images')
          .select()
          .eq('property_id', propertyId)
          .order('position', ascending: true);

      final data = response as List<dynamic>;

      return data
          .map(
            (item) => PropertyImage.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PropertyImage> uploadImage({
    required int propertyId,
    required String imageUrl,
    required String caption,
    required int position,
  }) async {
    try {
      final response = await SupabaseManager.supabase
          .from('property_images')
          .insert({
            'property_id': propertyId,
            'image_url': imageUrl,
            'caption': caption,
            'position': position,
          })
          .select()
          .single();

      return PropertyImage.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(int imageId) async {
    try {
      await SupabaseManager.supabase
          .from('property_images')
          .delete()
          .eq('id', imageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateImageCaption(int imageId, String caption) async {
    try {
      await SupabaseManager.supabase
          .from('property_images')
          .update({'caption': caption})
          .eq('id', imageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateImagePosition(int imageId, int position) async {
    try {
      await SupabaseManager.supabase
          .from('property_images')
          .update({'position': position})
          .eq('id', imageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reorderImages(List<PropertyImage> images) async {
    try {
      // Update all images with new positions
      for (int i = 0; i < images.length; i++) {
        await SupabaseManager.supabase
            .from('property_images')
            .update({'position': i})
            .eq('id', images[i].id);
      }
    } catch (e) {
      rethrow;
    }
  }
}