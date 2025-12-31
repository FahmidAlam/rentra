import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/widgets/property_grid.dart';

class MyPropertiesScreen extends StatefulWidget {
  final PropertyController propertyController;

  const MyPropertiesScreen({
    super.key,
    required this.propertyController,
  });

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.propertyController,
      builder: (context, _) {
        final controller = widget.propertyController;
        final myProperties = controller.myProperties;

        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (myProperties.isEmpty) {
          return const Center(child: Text('You have no properties yet'));
        }

        return PropertyGrid(properties: myProperties);
      },
    );
  }
}
