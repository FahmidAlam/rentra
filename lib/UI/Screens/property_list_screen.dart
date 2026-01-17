import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/UI/widgets/property_grid.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';
import 'package:rentra/core/theme/app_theme.dart';

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
            title: const Text('Public Properties'),
            centerTitle: true,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(PropertyController controller) {
    // Loading with theme color
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(RentraColors.darkTeal),
        ),
      );
    }

    // Empty state using RentraEmptyState
    if (controller.properties.isEmpty) {
      return RentraEmptyState(
        icon: Icons.home_outlined,
        title: 'No properties available',
        subtitle: 'Check back later for new listings',
      );
    }

    return PropertyGrid(properties: controller.properties);
  }
}