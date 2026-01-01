import 'package:flutter/material.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/Data/datasources/unit_remote_datasource.dart';
import 'package:rentra/Data/repositories/unit_repository.dart';
import 'package:rentra/UI/Screens/unit_list_screen.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Cover Image
            Image.network(
              property.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  /// City / Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${property.city}, ${property.address}',
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
                    property.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  /// Contact Owner (UI only for now)
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
                  // VIEW UNITS BUTTON (NEW)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('View Units'),
                      onPressed: () {
                        // Manual DI (same pattern as MainShell)
                        final unitController = UnitController(
                          UnitRepository(UnitRemoteDataSource()),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UnitListScreen(
                              property: property,
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
}
