import 'package:flutter/material.dart';
import 'package:rentra/UI/widgets/property_card.dart';
import 'package:rentra/core/models/property.dart';

class PropertyGrid extends StatelessWidget {
  final List<Property> properties;

  const PropertyGrid({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: properties.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        return PropertyCard(property: properties[index]);
      },
    );
  }
}