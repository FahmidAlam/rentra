

import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/supabase_client.dart';

class TenancyRequestsScreen extends StatefulWidget {
  const TenancyRequestsScreen({super.key});

  @override
  State<TenancyRequestsScreen> createState() =>
      _TenancyRequestsScreenState();
}

class _TenancyRequestsScreenState extends State<TenancyRequestsScreen> {
  late final TenancyController controller;
  bool _noUser = false;

  @override
  void initState() {
    super.initState();

    controller = AppDependencies.tenancyController;

    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      _noUser = true;
      return;
    }

    controller.loadPendingForOwner(currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_noUser) {
          return const Scaffold(
            body: Center(child: Text('Not signed in')),
          );
        }

        if (controller.pendingTenancies.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No pending tenancy requests'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tenancy Requests'),
          ),
          body: ListView.builder(
            itemCount: controller.pendingTenancies.length,
            itemBuilder: (_, index) {
              final tenancy =
                  controller.pendingTenancies[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    'Tenant ID: ${tenancy.tenantId}',
                  ),
                  subtitle: Text(
                    'Unit ID: ${tenancy.unitId}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await controller.approve(
                            tenancy.id,
                            tenancy.unitId,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await controller.reject(
                            tenancy.id,
                          );
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
