import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/widgets/property_card.dart';
import 'package:rentra/UI/Screens/add_edit_property_screen.dart';
import 'package:rentra/UI/Screens/property_image_management_screen.dart';

class MyPropertiesScreen extends StatelessWidget {
  final PropertyController propertyController;
  const MyPropertiesScreen({
    super.key,
    required this.propertyController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: propertyController,
      builder: (context, _) {
        if (propertyController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ SAFE: controller already handles auth
        final myProperties = propertyController.myProperties;
        if (myProperties.isEmpty) {
          return const Center(child: Text('You have no properties yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: myProperties.length,
          itemBuilder: (context, index) {
            final property = myProperties[index];
            return Dismissible(
              key: ValueKey(property.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Property'),
                    content: const Text(
                      'Are you sure you want to delete this property?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                propertyController.deleteProperty(property.id as int);
              },
              child: Stack(
                children: [
                  PropertyCard(property: property),
                  // ✅ FIXED: Action buttons without hero animation
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        // 📸 MANAGE IMAGES BUTTON
                        _buildActionButton(
                          context: context,
                          icon: Icons.image,
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PropertyImageManagementScreen(
                                  property: property,
                                ),
                              ),
                            );
                          },
                          tooltip: 'Manage Images',
                        ),
                        const SizedBox(height: 8),
                        // ✏️ EDIT PROPERTY BUTTON
                        _buildActionButton(
                          context: context,
                          icon: Icons.edit,
                          color: Colors.green,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditPropertyScreen(
                                  property: property,
                                  propertyController:
                                      propertyController,
                                ),
                              ),
                            );
                          },
                          tooltip: 'Edit Property',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ FIXED: Custom button without hero animation
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}