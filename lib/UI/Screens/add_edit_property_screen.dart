import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/supabase_client.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final PropertyController propertyController;
  final Property? property; // null = Add, not null = Edit

  const AddEditPropertyScreen({
    super.key,
    required this.propertyController,
    this.property,
  });

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  final currentUser= SupabaseManager.supabase.auth.currentUser;

  bool _isSubmitting = false;

  bool get isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.property?.title ?? '');
    _cityController =
        TextEditingController(text: widget.property?.city ?? '');
    _addressController =
        TextEditingController(text: widget.property?.address ?? '');
    _descriptionController =
        TextEditingController(text: widget.property?.description ?? '');
    _imageUrlController =
        TextEditingController(text: widget.property?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (title.isEmpty || city.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, City and Address are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (isEditing) {
        // EDIT PROPERTY (CORRECT CONTRACT)
        await widget.propertyController.updateProperty(
          widget.property!.id as int,
          title: title,
          city: city,
          address: address,
          description: description,
          imageUrl: imageUrl,
        );
      } else {
        // ADD PROPERTY
        await widget.propertyController.addProperty(
          Property(
            id: 0, // ignored by Supabase (use String)
            ownerId: currentUser?.id ?? '' ,
            title: title,
            city: city,
            address: address,
            description: description,
            imageUrl: imageUrl,
          ),
          title: title,
          address: address,
          city: city,
          description: description,
          coverImageUrl: imageUrl,
          galleryImages: const [],
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to save property')),
      // );
      debugPrint('Update property error: $e');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Property' : 'Add Property'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: 'Cover Image URL'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveProperty,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? 'Update Property' : 'Add Property'),
            ),
          ),
        ],
      ),
    );
  }
}
