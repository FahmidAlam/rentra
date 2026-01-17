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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
      ),
      body: AnimatedBuilder(
        animation: propertyController,
        builder: (context, _) {
          if (propertyController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final myProperties = propertyController.myProperties;

          if (myProperties.isEmpty) {
            return Center(
              child: Text(
                'You have no properties yet',
                style: textTheme.bodyLarge,
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myProperties.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final property = myProperties[index];

              return Dismissible(
                key: ValueKey(property.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.delete,
                    color: colorScheme.onError,
                  ),
                ),
                confirmDismiss: (_) async {
                  return showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
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
                  propertyController.deleteProperty(property.id);
                },
                child: Stack(
                  children: [
                    PropertyCard(property: property),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        children: [
                          _PropertyActionButton(
                            icon: Icons.image,
                            tooltip: 'Manage Images',
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyImageManagementScreen(
                                    property: property,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _PropertyActionButton(
                            icon: Icons.edit,
                            tooltip: 'Edit Property',
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditPropertyScreen(
                                    controller: propertyController,
                                    property: property,
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
              );
            },
          );
        },
      ),
    );
  }
}
class _PropertyActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _PropertyActionButton({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: foregroundColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
