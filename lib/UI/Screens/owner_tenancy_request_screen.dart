import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/supabase_client.dart';

class OwnerTenancyRequestsScreen extends StatefulWidget {
  final TenancyController controller;

  const OwnerTenancyRequestsScreen({super.key, required this.controller});

  @override
  State<OwnerTenancyRequestsScreen> createState() =>
      _OwnerTenancyRequestsScreenState();
}

class _OwnerTenancyRequestsScreenState
    extends State<OwnerTenancyRequestsScreen> {
  bool _noUser = false;
  @override
  void initState() {
    super.initState();
    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      _noUser = true;
      return;
    }

    widget.controller.loadPendingForOwner(currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_noUser) {
          return const Scaffold(
            body: Center(child: Text('Not signed in')),
          );
        }

        if (widget.controller.pendingTenancies.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No pending requests')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pending Requests')),
          body: ListView.builder(
            itemCount: widget.controller.pendingTenancies.length,
            itemBuilder: (_, index) {
              final req = widget.controller.pendingTenancies[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Unit ID: ${req.unitId}'),
                  subtitle: Text('Tenant: ${req.tenantId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          widget.controller.approve(req.id, req.unitId);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          widget.controller.reject(req.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
