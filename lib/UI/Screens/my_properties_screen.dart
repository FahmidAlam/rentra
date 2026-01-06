
// import 'package:flutter/material.dart';
// import 'package:rentra/Application/property_controller.dart';
// import 'package:rentra/UI/widgets/property_card.dart';
// import 'package:rentra/UI/Screens/add_edit_property_screen.dart';
// import 'package:rentra/UI/Screens/property_image_management_screen.dart';

// class MyPropertiesScreen extends StatelessWidget {
//   final PropertyController propertyController;

//   const MyPropertiesScreen({
//     super.key,
//     required this.propertyController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;

//     return Scaffold(
//       // ✅ Uses appBarTheme automatically
//       appBar: AppBar(
//         title: const Text('My Properties'),
//         actions: [
//           IconButton(
//             tooltip: 'Add Property',
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddEditPropertyScreen(
//                     controller: propertyController,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),

//       body: AnimatedBuilder(
//         animation: propertyController,
//         builder: (context, _) {
//           if (propertyController.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final myProperties = propertyController.myProperties;

//           if (myProperties.isEmpty) {
//             return Center(
//               child: Text(
//                 'You have no properties yet',
//                 style: textTheme.bodyLarge,
//               ),
//             );
//           }

//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 0.75,
//             ),
//             itemCount: myProperties.length,
//             itemBuilder: (context, index) {
//               final property = myProperties[index];

//               return Dismissible(
//                 key: ValueKey(property.id),
//                 direction: DismissDirection.endToStart,
//                 background: Container(
//                   color: colorScheme.error,
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 16),
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 confirmDismiss: (_) async {
//                   return await showDialog<bool>(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Delete Property'),
//                       content: const Text(
//                         'Are you sure you want to delete this property?',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Cancel'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text('Delete'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 onDismissed: (_) {
//                   propertyController.deleteProperty(property.id);
//                 },
//                 child: Stack(
//                   children: [
//                     // ✅ PropertyCard already follows CardTheme
//                     PropertyCard(property: property),

//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Column(
//                         children: [
//                           _buildActionButton(
//                             icon: Icons.image,
//                             color: colorScheme.primary,
//                             tooltip: 'Manage Images',
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       PropertyImageManagementScreen(
//                                     property: property,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 8),
//                           _buildActionButton(
//                             icon: Icons.edit,
//                             color: colorScheme.secondary,
//                             tooltip: 'Edit Property',
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AddEditPropertyScreen(
//                                     controller: propertyController,
//                                     property: property,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ✅ Theme-aware custom action button
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//     required String tooltip,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: Tooltip(
//         message: tooltip,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
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
      // ✅ Fully theme-driven AppBar
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
                  child: const Icon(Icons.delete, color: Colors.white),
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
                    // ✅ Card respects CardTheme automatically
                    PropertyCard(property: property),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        children: [
                          _ActionButton(
                            icon: Icons.image,
                            tooltip: 'Manage Images',
                            color: colorScheme.primary,
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
                          _ActionButton(
                            icon: Icons.edit,
                            tooltip: 'Edit Property',
                            color: colorScheme.secondary,
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

/// ✅ Small internal widget to keep UI consistent & readable
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
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
              color: color,
              shape: BoxShape.circle,
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
