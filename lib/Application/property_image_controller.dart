import 'package:flutter/material.dart';
import 'package:rentra/Data/datasources/property_image_remote_datasource.dart';
import 'package:rentra/core/models/property_image.dart';

class PropertyImageController extends ChangeNotifier {
  final IPropertyImageRemoteDataSource remoteDataSource;

  PropertyImageController(this.remoteDataSource);

  // State
  List<PropertyImage> images = [];
  bool isLoading = false;
  String? errorMessage;
  int? propertyId;

  /// Load images for a property
  Future<void> loadImages(int propertyId) async {
    this.propertyId = propertyId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      images = await remoteDataSource.fetchImagesByProperty(propertyId);

    } catch (e) {
      errorMessage = 'Failed to load images: $e';

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Upload a new image - FIXED: Proper state management
  Future<bool> uploadImage({
    required String imageUrl,
    required String caption,
  }) async {
    if (propertyId == null) {
      errorMessage = 'Property ID not set';
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newPosition = images.length;
      final image = await remoteDataSource.uploadImage(
        propertyId: propertyId!,
        imageUrl: imageUrl,
        caption: caption,
        position: newPosition,
      );

      images.add(image);  // ✅ Add to list
      print('✅ Image uploaded successfully: ${image.id}');
      errorMessage = null;
      notifyListeners();  // ✅ Notify UI to refresh
      return true;
    } catch (e) {
      errorMessage = 'Failed to upload image: $e';
      notifyListeners();  // ✅ Notify UI of error
      return false;
    } finally {
      isLoading = false;
      notifyListeners();  // ✅ Always notify
    }
  }

  /// Delete an image
  Future<bool> deleteImage(int imageId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.deleteImage(imageId);

      images.removeWhere((img) => img.id == imageId);

      // Reorder remaining images
      for (int i = 0; i < images.length; i++) {
        images[i] = images[i].copyWith(position: i);
      }

      // Update positions in database
      await remoteDataSource.reorderImages(images);

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete image: $e';

      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update caption for an image
  Future<bool> updateCaption(int imageId, String newCaption) async {
    try {
      await remoteDataSource.updateImageCaption(imageId, newCaption);

      final index = images.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        images[index] = images[index].copyWith(caption: newCaption);
      }

      print('✅ Caption updated');
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update caption: $e';

      notifyListeners();
      return false;
    }
  }

  /// Reorder images (after drag and drop)
  Future<bool> reorderImages(List<PropertyImage> reorderedImages) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      images = reorderedImages;

      await remoteDataSource.reorderImages(images);


      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to reorder images: $e';

      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}