import 'package:flutter/material.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/Data/datasources/unit_remote_datasource.dart';
import 'package:rentra/Data/datasources/property_image_remote_datasource.dart';
import 'package:rentra/Data/repositories/unit_repository.dart';
import 'package:rentra/core/models/property_image.dart';
import 'package:rentra/UI/Screens/unit_list_screen.dart';
import 'package:rentra/UI/Screens/full_screen_image_viewer.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

/// ✅ REFACTORED PropertyDetailsScreen
/// 
/// Changes made:
/// - Uses RentraPrimaryButton and RentraSecondaryButton
/// - Uses VSpace for spacing
/// - Theme-colored SnackBars
/// - Consistent styling with other screens
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
      // ✅ AppBar uses theme
      appBar: AppBar(
        title: Text(widget.property.title),
      ),
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
                  // ✅ Title with theme text style
                  Text(
                    widget.property.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const VSpace(8),

                  // ✅ City / Address with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: RentraColors.darkTeal,
                      ),
                      const HSpace(4),
                      Expanded(
                        child: Text(
                          '${widget.property.city}, ${widget.property.address}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const VSpace(16),

                  // ✅ Description section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const VSpace(8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RentraColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.property.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const VSpace(24),

                  // ✅ PRIMARY BUTTON - Contact Owner
                  RentraPrimaryButton(
                    label: 'Contact Owner',
                    icon: Icons.phone,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Owner contact feature coming soon'),
                          backgroundColor: RentraColors.darkTeal,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  const VSpace(12),

                  // ✅ SECONDARY BUTTON - View Units
                  RentraSecondaryButton(
                    label: 'View Available Units',
                    icon: Icons.meeting_room,
                    color: RentraColors.limeGreen,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMAGE CAROUSEL WIDGET (unchanged - already well implemented)
  Widget _buildImageCarousel() {
    // Loading state
    if (_imagesLoading) {
      return Container(
        height: 250,
        color: RentraColors.background,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(RentraColors.darkTeal),
              ),
              VSpace(12),
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
            color: RentraColors.background,
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
                  images: _propertyImages.map((img) => img.imageUrl).toList(),
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
                  color: RentraColors.background,
                  child: const Center(
                    child: Icon(Icons.broken_image),
                  ),
                ),
              ),
              // ✅ ZOOM HINT with theme colors
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
                      HSpace(4),
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
                      ? RentraColors.darkTeal
                      : RentraColors.divider,
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
                            ? RentraColors.darkTeal
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: RentraColors.darkTeal.withOpacity(0.3),
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
                          color: RentraColors.background,
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

/* ✅ IMPROVEMENTS SUMMARY:
 * 
 * Before:
 * - Generic ElevatedButton.icon widgets
 * - SizedBox for spacing
 * - No theme integration in buttons
 * - Inconsistent with other screens
 * 
 * After:
 * - RentraPrimaryButton for main action (Contact Owner)
 * - RentraSecondaryButton for secondary action (View Units)
 * - VSpace/HSpace for spacing
 * - Theme colors in SnackBars and indicators
 * - Consistent with LoginScreen, RegisterScreen, etc.
 * - Better visual hierarchy
 */