import 'package:flutter/material.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/UI/Screens/add_unit_screen.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/core/theme/app_theme.dart';

class UnitListScreen extends StatefulWidget {
  final Property property;
  final UnitController controller;

  const UnitListScreen({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  bool _isPropertyOwner = false;
  bool _loadingOwnershipCheck = true;

  @override
  void initState() {
    super.initState();
    _checkPropertyOwnership();
    widget.controller.loadUnits(widget.property.id);
  }

  Future<void> _checkPropertyOwnership() async {
    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      setState(() => _loadingOwnershipCheck = false);
      return;
    }

    setState(() {
      _isPropertyOwner = widget.property.ownerId == currentUser.id;
      _loadingOwnershipCheck = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        if (widget.controller.isLoading || _loadingOwnershipCheck) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Units - ${widget.property.title}'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Units - ${widget.property.title}'),
            elevation: 0,
          ),
          floatingActionButton: _isPropertyOwner
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddUnitScreen(
                          propertyId: widget.property.id,
                          controller: widget.controller,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Unit'),
                  backgroundColor: RentraColors.darkTeal,
                )
              : null,
          body: widget.controller.units.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await widget.controller.loadUnits(widget.property.id);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.controller.units.length,
                    itemBuilder: (_, index) {
                      final unit = widget.controller.units[index];
                      return _buildUnitCard(unit);
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _isPropertyOwner ? 'No units added yet' : 'No units available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPropertyOwner
                ? 'Add your first unit using the + button'
                : 'Check back later for available units',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard(unit) {
    final isAvailable = unit.isAvailable;
    final statusColor = isAvailable ? RentraColors.success : RentraColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Unit Number
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: RentraColors.darkTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.meeting_room,
                          color: RentraColors.darkTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit ${unit.unitNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: RentraColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳${unit.rent.toStringAsFixed(0)}/month',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RentraColors.darkTeal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      border: Border.all(color: statusColor, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.lock,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAvailable ? 'AVAILABLE' : 'OCCUPIED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Section
              if (_isPropertyOwner)
                _buildOwnerActions(unit)
              else
                _buildTenantActions(unit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerActions(unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RentraColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.toggle_on,
                color: RentraColors.darkTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Availability',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: RentraColors.darkText,
                ),
              ),
            ],
          ),
          Switch(
            value: unit.isAvailable,
            activeColor: RentraColors.success,
            onChanged: (_) async {
              await _handleToggleAvailability(unit);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleAvailability(unit) async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Updating unit status...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      await widget.controller.toggleAvailability(unit);

      if (!mounted) return;

      // Clear loading snackbar
      ScaffoldMessenger.of(context).clearSnackBars();

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                unit.isAvailable ? Icons.lock : Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                unit.isAvailable
                    ? '🔒 Unit marked as unavailable'
                    : '✅ Unit marked as available',
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh the list
      await widget.controller.loadUnits(widget.property.id);
    } catch (e) {
      if (!mounted) return;

      // Clear loading snackbar
      ScaffoldMessenger.of(context).clearSnackBars();

      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('❌ $errorMessage')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildTenantActions(unit) {
    if (!unit.isAvailable) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RentraColors.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: RentraColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock,
              color: RentraColors.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'This unit is currently occupied',
                style: TextStyle(
                  fontSize: 13,
                  color: RentraColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _handleRequestUnit(unit);
        },
        icon: const Icon(Icons.send),
        label: const Text(
          'Request This Unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: RentraColors.darkTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _handleRequestUnit(unit) async {
    final user = SupabaseManager.supabase.auth.currentUser;

    // Check authentication
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Please sign in to request units'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Sending request...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Attempt to send request
      final success = await AppDependencies.tenancyController.requestTenancy(
        tenantId: user.id,
        unitId: unit.id,
      );

      if (!mounted) return;

      // Clear loading snackbar
      ScaffoldMessenger.of(context).clearSnackBars();

      if (success) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('✅ Tenancy request sent successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Refresh the unit list
        await widget.controller.loadUnits(widget.property.id);
      } else {
        // Failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppDependencies.tenancyController.errorMessage ??
                        '❌ Request failed',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Error (duplicate request, unit unavailable, etc.)
      if (!mounted) return;

      // Clear loading snackbar
      ScaffoldMessenger.of(context).clearSnackBars();

      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('❌ $errorMessage')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      // Refresh list in case unit status changed
      await widget.controller.loadUnits(widget.property.id);
    }
  }
}