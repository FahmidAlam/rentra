import 'package:flutter/material.dart';
import 'package:rentra/UI/widgets/property_grid.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/core/models/property.dart';

class PropertyListScreen extends StatelessWidget {
  final PropertyController propertyController;

  const PropertyListScreen({
    super.key,
    required this.propertyController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Properties')),
      body: FutureBuilder<List<Property>>(
        future: propertyController.fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No properties found'));
          }
          
          final properties = snapshot.data ?? [];
          return PropertyGrid(properties: properties);
        },
      ),
    );
  }
}