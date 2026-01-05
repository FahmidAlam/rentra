import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';
import 'package:rentra/core/models/property.dart';

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

  bool _loading = false;

  // TEMP placeholders (future: image picker)
  String coverImageUrl = 'https://placehold.co/600x400';
  List<String> galleryImages = [];

  @override
  void initState() {
    super.initState();

    // EDIT MODE → prefill fields
    if (widget.property != null) {
      _titleCtrl.text = widget.property!.title;
      _addressCtrl.text = widget.property!.address;
      _cityCtrl.text = widget.property!.city;
      _descCtrl.text = widget.property!.description;
      coverImageUrl = widget.property!.imageUrl;
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      if (widget.property == null) {
        // --------------------
        // ADD PROPERTY
        // --------------------
        await widget.controller.addProperty(
          title: _titleCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          coverImageUrl: coverImageUrl,
          galleryImages: galleryImages,
        );
      } else {
        // --------------------
        // EDIT PROPERTY
        // --------------------
        await widget.controller.updateProperty(
          widget.property!.id,
          title: _titleCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageUrl: coverImageUrl,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.property != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Property' : 'Add Property'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Update Property' : 'Create Property'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
