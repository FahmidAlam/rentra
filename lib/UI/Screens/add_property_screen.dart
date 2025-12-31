import 'package:flutter/material.dart';
import 'package:rentra/Application/property_controller.dart';

class AddPropertyScreen extends StatefulWidget {
  final PropertyController controller;

  const AddPropertyScreen({super.key, required this.controller});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _titleCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _loading = false;

  // TEMP: replace later with image picker
  String coverImageUrl = 'https://placehold.co/600x400';
  List<String> galleryImages = [];

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      await widget.controller.addProperty(
        title: _titleCtrl.text,
        address: _addressCtrl.text,
        city: _cityCtrl.text,
        description: _descCtrl.text,
        coverImageUrl: coverImageUrl,
        galleryImages: galleryImages,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City')),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create Property'),
            ),
          ],
        ),
      ),
    );
  }
}
