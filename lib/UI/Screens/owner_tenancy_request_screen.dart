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
        // 🔄 LOADING STATE
        if (widget.controller.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading requests...'),
                ],
              ),
            ),
          );
        }

        //  NOT SIGNED IN STATE
        if (_noUser) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Please sign in to view requests',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        //  NO REQUESTS STATE
        if (widget.controller.pendingTenancies.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tenants will appear here when they request units',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        //  REQUESTS LIST
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pending Requests'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.controller.pendingTenancies.length,
            itemBuilder: (_, index) {
              final req = widget.controller.pendingTenancies[index];

              return _buildRequestCard(req);
            },
          ),
        );
      },
    );
  }

  // STEP 5: IMPROVED REQUEST CARD WIDGET
  Widget _buildRequestCard(dynamic req) {
    // Extract tenant ID (first 8 chars for display)
    final tenantIdShort = req.tenantId.substring(0, 8);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Colors.blue.shade400,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  HEADER: Unit Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit #${req.unitId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tenant: $tenantIdShort...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  //  STATUS BADGE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              //  REQUEST DETAILS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn('Unit ID', req.unitId.toString()),
                    const SizedBox(width: 8),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoColumn(
                      'Tenant ID',
                      tenantIdShort,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              //  ACTION BUTTONS
              Row(
                children: [
                  //  APPROVE BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _showConfirmDialog(
                          context,
                          title: 'Approve Request?',
                          message: 'Approve this tenancy request?',
                          onConfirm: () {
                            widget.controller.approve(req.id, req.unitId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Request approved'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  //  REJECT BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _showConfirmDialog(
                          context,
                          title: 'Reject Request?',
                          message: 'Reject this tenancy request?',
                          onConfirm: () {
                            widget.controller.reject(req.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Request rejected'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for info display
  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method for confirmation dialog
  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}