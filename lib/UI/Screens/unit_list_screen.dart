
import 'package:flutter/material.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/UI/Screens/add_unit_screen.dart';
import 'package:rentra/core/supabase_client.dart';

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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Units - ${widget.property.title}'),
          ),
          floatingActionButton: _isPropertyOwner
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
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
                )
              : null,
          body: widget.controller.units.isEmpty
              ? const Center(child: Text('No units available'))
              : ListView.builder(
                  itemCount: widget.controller.units.length,
                  itemBuilder: (_, index) {
                    final unit = widget.controller.units[index];

                    return ListTile(
                      title: Text('Unit ${unit.unitNumber}'),
                      subtitle: Text('Rent: ৳${unit.rent}'),
                      trailing: _isPropertyOwner
                          ? Switch(
                              value: unit.isAvailable,
                              onChanged: (_) {
                                widget.controller
                                    .toggleAvailability(unit);
                              },
                            )
                          : ElevatedButton(
                              child: const Text('Request'),
                              onPressed: unit.isAvailable
                                  ? () async {
                                      final user = SupabaseManager
                                          .supabase.auth.currentUser;

                                      if (user == null) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please sign in to request'),
                                          ),
                                        );
                                        return;
                                      }

                                      final success = await AppDependencies
                                          .tenancyController
                                          .requestTenancy(
                                        tenantId: user.id,
                                        unitId: unit.id,
                                      );

                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Tenancy request sent'
                                                : AppDependencies
                                                        .tenancyController
                                                        .errorMessage ??
                                                    'Request failed',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                    );
                  },
                ),
        );
      },
    );
  }
}

