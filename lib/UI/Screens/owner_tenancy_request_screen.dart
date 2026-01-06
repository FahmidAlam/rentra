import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/models/tenancy.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

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
  Map<String, dynamic> _tenantDetails = {};

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

  Future<Map<String, dynamic>?> _fetchTenantProfile(String tenantId) async {
    // Return cached data if available
    if (_tenantDetails.containsKey(tenantId)) {
      return _tenantDetails[tenantId];
    }
    
    try {
      final response = await SupabaseManager.supabase
          .from('profiles')
          .select()
          .eq('id', tenantId)
          .single();

      _tenantDetails[tenantId] = response;
      return response;
    } catch (e) {
      print('Error fetching tenant profile: $e');
      _tenantDetails[tenantId] = null;
      return null;
    }
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
                  VSpace(16),
                  Text('Loading requests...'),
                ],
              ),
            ),
          );
        }

        // ❌ NOT SIGNED IN
        if (_noUser) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              centerTitle: true,
            ),
            body: RentraEmptyState(
              icon: Icons.lock,
              title: 'Please sign in',
              subtitle: 'Sign in to view tenancy requests',
            ),
          );
        }

        // 📭 NO REQUESTS
        if (widget.controller.pendingTenancies.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pending Requests'),
              centerTitle: true,
            ),
            body: RentraEmptyState(
              icon: Icons.inbox,
              title: 'No pending requests',
              subtitle: 'Tenants will appear here when they request units',
            ),
          );
        }

        // ✅ REQUESTS LIST
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
              // req is a Tenancy object - we need to get created_at from raw data
              // For now, use current time as fallback since Tenancy model doesn't have createdAt
              return _buildRequestCardWithTenantInfo(req);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestCardWithTenantInfo(Tenancy req) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchTenantProfile(req.tenantId),
      builder: (context, snapshot) {
        // Show loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  const Text('Loading tenant info...'),
                ],
              ),
            ),
          );
        }
        
        // Get tenant info from snapshot data
        final tenantInfo = snapshot.data;
        final tenantEmail = tenantInfo?['email'] ?? 'N/A';
        final tenantName = tenantInfo?['full_name'] ?? 'N/A';
        final tenantPhone = tenantInfo?['phone'] ?? 'N/A';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: RentraColors.pending,
                width: 4,
              ),
            ),
          ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 TENANT INFO HEADER
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RentraColors.limeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: RentraColors.limeGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: RentraColors.limeGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 20),
                            ),
                            const HSpace(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tenantName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: RentraColors.darkText,
                                    ),
                                  ),
                                  const VSpace(2),
                                  Text(
                                    tenantEmail,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: RentraColors.lightText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const VSpace(12),
                        Divider(
                          color: RentraColors.limeGreen.withOpacity(0.3),
                          height: 1,
                        ),
                        const VSpace(12),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 14, color: RentraColors.darkTeal),
                            const HSpace(8),
                            Text(
                              tenantPhone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: RentraColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const VSpace(16),

                  // 🏠 UNIT & PROPERTY INFO
                  Text(
                    'Property Unit Details',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const VSpace(8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RentraColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        RentraInfoRow(
                          icon: Icons.domain,
                          label: 'Unit ID',
                          value: req.unitId.toString(),
                        ),
                        const VSpace(12),
                        RentraInfoRow(
                          icon: Icons.calendar_month,
                          label: 'Requested On',
                          value: req.startDate != null 
                              ? _formatDate(req.startDate!)
                              : 'N/A',
                        ),
                        const VSpace(12),
                        RentraInfoRow(
                          icon: Icons.schedule,
                          label: 'Status',
                          value: req.status.toUpperCase(),
                        ),
                      ],
                    ),
                  ),

                  const VSpace(16),

                  // ⏳ STATUS BADGE
                  Center(
                    child: RentraStatusBadge(
                      label: req.status,
                      status: req.status,
                      icon: Icons.schedule,
                    ),
                  ),

                  const VSpace(16),

                  // 🔘 ACTION BUTTONS
                  Row(
                    children: [
                      // ✅ APPROVE BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmDialog(
                            context,
                            title: 'Approve Request?',
                            message:
                                'Approve tenancy request from ${tenantName}?',
                            onConfirm: () {
                              widget.controller.approve(
                                  req.id, req.unitId);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Request approved'),
                                  backgroundColor: RentraColors.success,
                                ),
                              );
                            },
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RentraColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const HSpace(12),

                      // ❌ REJECT BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmDialog(
                            context,
                            title: 'Reject Request?',
                            message:
                                'Reject tenancy request from ${tenantName}?',
                            onConfirm: () {
                              widget.controller.reject(req.id);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Request rejected'),
                                  backgroundColor: RentraColors.error,
                                ),
                              );
                            },
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RentraColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
      },
    );
  }

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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}