import 'package:flutter/material.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/Data/datasources/unit_remote_datasource.dart';
import 'package:rentra/Data/datasources/property_image_remote_datasource.dart';
import 'package:rentra/Data/repositories/unit_repository.dart';
import 'package:rentra/core/models/property_image.dart';
import 'package:rentra/UI/Screens/unit_list_screen.dart';
import 'package:rentra/UI/Screens/full_screen_image_viewer.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _currentImageIndex = 0;
  List<PropertyImage> _propertyImages = [];
  bool _imagesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPropertyImages();
  }

  Future<void> _loadPropertyImages() async {
    try {
      final imageDataSource = PropertyImageRemoteDataSource();
      final images = await imageDataSource.fetchImagesByProperty(
        widget.property.id,
      );
      if (mounted) {
        setState(() {
          _propertyImages = images;
          _imagesLoading = false;
        });
      }
    } catch (e) {
      print('Error loading images: $e');
      if (mounted) {
        setState(() {
          _imagesLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.property.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE CAROUSEL
            _buildImageCarousel(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    widget.property.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  /// City / Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.property.city}, ${widget.property.address}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.property.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  /// Contact Owner
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Owner contact coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact Owner'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // VIEW UNITS BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('View Units'),
                      onPressed: () {
                        final unitController = UnitController(
                          UnitRepository(UnitRemoteDataSource()),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UnitListScreen(
                              property: widget.property,
                              controller: unitController,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMAGE CAROUSEL WIDGET
  Widget _buildImageCarousel() {
    // Loading state
    if (_imagesLoading) {
      return Container(
        height: 250,
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading images...'),
            ],
          ),
        ),
      );
    }

    // No images - show property cover image
    if (_propertyImages.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImageViewer(
                images: [widget.property.imageUrl],
              ),
            ),
          );
        },
        child: Image.network(
          widget.property.imageUrl,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 250,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported),
            ),
          ),
        ),
      );
    }

    // Show carousel with gallery images
    return Column(
      children: [
        // MAIN CAROUSEL IMAGE
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(
                  images:
                      _propertyImages.map((img) => img.imageUrl).toList(),
                  initialIndex: _currentImageIndex,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Image.network(
                _propertyImages[_currentImageIndex].imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image),
                  ),
                ),
              ),
              // 🖱️ ZOOM HINT
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Tap to expand',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // IMAGE INDICATOR DOTS
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _propertyImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? Colors.blue.shade600
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // THUMBNAIL GALLERY (Only if more than 1 image)
        if (_propertyImages.length > 1)
          Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _propertyImages.length,
              itemBuilder: (context, index) {
                final isActive = _currentImageIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive
                            ? Colors.blue.shade600
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _propertyImages[index].imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}