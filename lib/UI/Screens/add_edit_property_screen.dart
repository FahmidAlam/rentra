import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

/// ✅ REFACTORED AddEditPropertyScreen
/// 
/// Changes made:
/// - Added proper labels with theme text styles
/// - Added icons to all text fields with theme colors
/// - Uses VSpace for spacing instead of SizedBox
/// - Uses RentraPrimaryButton with loading state
/// - Added helpful hint text
/// - Proper error handling with theme colors
class AddEditPropertyScreen extends StatefulWidget {
  final PropertyController controller;
  final Property? property; // null = ADD, not null = EDIT

  const AddEditPropertyScreen({
    super.key,
    required this.controller,
    this.property,
  });

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _titleCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _coverImageCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // EDIT MODE → prefill fields
    if (widget.property != null) {
      final p = widget.property!;
      _titleCtrl.text = p.title;
      _addressCtrl.text = p.address;
      _cityCtrl.text = p.city;
      _descCtrl.text = p.description;
      _coverImageCtrl.text = p.imageUrl;
    }
  }

  Future<void> _submit() async {
    // ✅ Validation
    if (_titleCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _coverImageCtrl.text.trim().isEmpty) {
      _showErrorSnackBar('All fields are required');
      return;
    }

    setState(() => _loading = true);
    try {
      if (widget.property == null) {
        // ADD PROPERTY
        await widget.controller.addProperty(
          title: _titleCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          coverImageUrl: _coverImageCtrl.text.trim(),
          galleryImages: const [],
        );
        if (!mounted) return;
        _showSuccessSnackBar('Property created successfully!');
      } else {
        // EDIT PROPERTY
        await widget.controller.updateProperty(
          widget.property!.id,
          title: _titleCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageUrl: _coverImageCtrl.text.trim(),
        );
        if (!mounted) return;
        _showSuccessSnackBar('Property updated successfully!');
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RentraColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: RentraColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    _coverImageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;
    return Scaffold(
      // ✅ AppBar uses theme
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Property' : 'Add Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ PROPERTY TITLE
            Text(
              'Property Title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _titleCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'e.g., Modern Apartment in Gulshan',
                prefixIcon: const Icon(Icons.home),
                prefixIconColor: RentraColors.darkTeal,
              ),
            ),
            const VSpace(16),

            // ✅ ADDRESS
            Text(
              'Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _addressCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'House/Road number',
                prefixIcon: const Icon(Icons.location_on),
                prefixIconColor: RentraColors.darkTeal,
              ),
            ),
            const VSpace(16),

            // ✅ CITY
            Text(
              'City',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _cityCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'e.g., Dhaka, Chittagong',
                prefixIcon: const Icon(Icons.location_city),
                prefixIconColor: RentraColors.darkTeal,
              ),
            ),
            const VSpace(16),

            // ✅ DESCRIPTION
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _descCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'Describe your property in detail...',
                prefixIcon: const Icon(Icons.description),
                prefixIconColor: RentraColors.darkTeal,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const VSpace(16),

            // ✅ COVER IMAGE URL
            Text(
              'Cover Image URL',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _coverImageCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.image),
                prefixIconColor: RentraColors.darkTeal,
              ),
              keyboardType: TextInputType.url,
            ),
            const VSpace(8),
            Text(
              'You can manage additional images after creating the property',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RentraColors.lightText,
                  ),
            ),
            const VSpace(24),

            // ✅ SUBMIT BUTTON using RentraPrimaryButton
            RentraPrimaryButton(
              label: isEdit ? 'Update Property' : 'Create Property',
              icon: isEdit ? Icons.update : Icons.add_home,
              onPressed: _submit,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

/* ✅ IMPROVEMENTS SUMMARY:
 * 
 * Before:
 * - Generic TextFields with no context
 * - No validation feedback
 * - SizedBox for spacing
 * - Generic ElevatedButton
 * - Poor loading state handling
 * 
 * After:
 * - Labeled fields with theme text styles
 * - Helpful hint text for each field
 * - Icons with theme colors
 * - VSpace for consistent spacing
 * - RentraPrimaryButton with proper loading state
 * - Validation with clear error messages
 * - Success/error SnackBars with theme colors
 * - Disabled fields during loading
 */