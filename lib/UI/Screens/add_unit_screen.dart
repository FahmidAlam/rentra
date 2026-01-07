import 'package:flutter/material.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

/// ✅ REFACTORED AddUnitScreen
/// 
/// Changes made:
/// - Added proper labels with theme text styles
/// - Added icons to text fields with theme colors
/// - Uses VSpace for spacing
/// - Uses RentraPrimaryButton with loading state
/// - Added helpful hint text
/// - Proper validation and error handling
/// - Theme-colored SnackBars
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
    // ✅ VALIDATION
    if (_unitNumberCtrl.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter unit number');
      return;
    }

    if (_rentCtrl.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter rent amount');
      return;
    }

    final rent = double.tryParse(_rentCtrl.text.trim());
    if (rent == null || rent <= 0) {
      _showErrorSnackBar('Please enter a valid rent amount');
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.controller.addUnit(
        propertyId: widget.propertyId,
        unitNumber: _unitNumberCtrl.text.trim(),
        rent: rent,
      );

      if (!mounted) return;
      _showSuccessSnackBar('Unit added successfully!');
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
    _unitNumberCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar uses theme
      appBar: AppBar(
        title: const Text('Add Unit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ INFO CARD explaining what a unit is
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RentraColors.limeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RentraColors.limeGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: RentraColors.limeGreen,
                    size: 20,
                  ),
                  const HSpace(12),
                  Expanded(
                    child: Text(
                      'A unit is a rentable space within your property (e.g., apartment, room)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: RentraColors.darkText,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const VSpace(24),

            // ✅ UNIT NUMBER
            Text(
              'Unit Number',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _unitNumberCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'e.g., A-101, 2B, Room 5',
                prefixIcon: const Icon(Icons.meeting_room),
                prefixIconColor: RentraColors.darkTeal,
              ),
            ),
            const VSpace(16),

            // ✅ MONTHLY RENT
            Text(
              'Monthly Rent (৳)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const VSpace(8),
            TextField(
              controller: _rentCtrl,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'Enter monthly rent amount',
                prefixIcon: const Icon(Icons.attach_money),
                prefixIconColor: RentraColors.darkTeal,
              ),
              keyboardType: TextInputType.number,
            ),
            const VSpace(8),
            Text(
              'This is the amount tenants will pay monthly',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RentraColors.lightText,
                  ),
            ),
            const VSpace(32),

            // ✅ SUBMIT BUTTON using RentraPrimaryButton
            RentraPrimaryButton(
              label: 'Add Unit',
              icon: Icons.add,
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
 * - Basic TextField with no context
 * - Generic button
 * - SizedBox spacing
 * - Minimal validation
 * - No user guidance
 * 
 * After:
 * - Labeled fields with theme text styles
 * - Helpful hint text and descriptions
 * - Info card explaining what a unit is
 * - Icons with theme colors
 * - VSpace/HSpace for consistent spacing
 * - RentraPrimaryButton with loading state
 * - Proper validation with clear messages
 * - Theme-colored SnackBars
 * - Fields disabled during loading
 * - Better UX overall
 */