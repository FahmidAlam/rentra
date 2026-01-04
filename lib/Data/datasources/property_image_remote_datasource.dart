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
      print('🖼️ Fetching images for property: $propertyId');

      final response = await SupabaseManager.supabase
          .from('property_images')
          .select()
          .eq('property_id', propertyId)
          .order('position', ascending: true);

      final data = response as List<dynamic>;
      print('✅ Found ${data.length} images for property $propertyId');

      return data
          .map(
            (item) => PropertyImage.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching images: $e');
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
      print('⏳ Uploading image for property: $propertyId');

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

      final image = PropertyImage.fromJson(response);
      print('✅ Image uploaded successfully: ${image.id}');
      return image;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(int imageId) async {
    try {
      print('⏳ Deleting image: $imageId');

      await SupabaseManager.supabase
          .from('property_images')
          .delete()
          .eq('id', imageId);

      print('✅ Image deleted successfully: $imageId');
    } catch (e) {
      print('❌ Error deleting image: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateImageCaption(int imageId, String caption) async {
    try {
      print('⏳ Updating caption for image: $imageId');

      await SupabaseManager.supabase
          .from('property_images')
          .update({'caption': caption})
          .eq('id', imageId);

      print('✅ Caption updated successfully: $imageId');
    } catch (e) {
      print('❌ Error updating caption: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateImagePosition(int imageId, int position) async {
    try {
      print('⏳ Updating position for image: $imageId to $position');

      await SupabaseManager.supabase
          .from('property_images')
          .update({'position': position})
          .eq('id', imageId);

      print('✅ Position updated successfully: $imageId');
    } catch (e) {
      print('❌ Error updating position: $e');
      rethrow;
    }
  }

  @override
  Future<void> reorderImages(List<PropertyImage> images) async {
    try {
      print('⏳ Reordering ${images.length} images');

      // Update all images with new positions
      for (int i = 0; i < images.length; i++) {
        await SupabaseManager.supabase
            .from('property_images')
            .update({'position': i})
            .eq('id', images[i].id);
      }

      print('✅ All images reordered successfully');
    } catch (e) {
      print('❌ Error reordering images: $e');
      rethrow;
    }
  }
}