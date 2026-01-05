import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/widgets/property_grid.dart';

class PropertyListScreen extends StatefulWidget {
  final PropertyController propertyController;

  const PropertyListScreen({
    super.key,
    required this.propertyController,
  });

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.propertyController,
      builder: (context, _) {
        final controller = widget.propertyController;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Public Properties',
              style: TextStyle(
                color: Color.fromARGB(255, 3, 56, 99),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(PropertyController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.properties.isEmpty) {
      return const Center(child: Text('No properties found'));
    }

    return PropertyGrid(properties: controller.properties);
  }
}
