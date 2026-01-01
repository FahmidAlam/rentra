import 'package:flutter/material.dart';
import 'package:rentra/Application/unit_controller.dart';

class AddUnitScreen extends StatefulWidget {
  final int propertyId;
  final UnitController controller;

  const AddUnitScreen({
    super.key,
    required this.propertyId,
    required this.controller,
  });

  @override
  State<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  final _unitNumberCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_unitNumberCtrl.text.isEmpty || _rentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.controller.addUnit(
        propertyId: widget.propertyId,
        unitNumber: _unitNumberCtrl.text.trim(),
        rent: double.parse(_rentCtrl.text),
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
      appBar: AppBar(title: const Text('Add Unit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _unitNumberCtrl,
              decoration: const InputDecoration(labelText: 'Unit Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rentCtrl,
              decoration: const InputDecoration(labelText: 'Monthly Rent'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Add Unit'),
            ),
          ],
        ),
      ),
    );
  }
}
