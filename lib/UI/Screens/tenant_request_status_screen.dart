import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

class TenantRequestStatusScreen extends StatefulWidget {
  const TenantRequestStatusScreen({super.key});

  @override
  State<TenantRequestStatusScreen> createState() =>
      _TenantRequestStatusScreenState();
}

class _TenantRequestStatusScreenState extends State<TenantRequestStatusScreen> {
  late final TenancyController _controller;
  bool _noUser = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AppDependencies.tenancyController;

    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      _noUser = true;
      return;
    }

    _loadTenantRequests(currentUser.id);
  }

  Future<void> _loadTenantRequests(String tenantId) async {
    try {
      print('🔄 Loading requests for tenant: $tenantId');

      final response = await SupabaseManager.supabase
          .from('tenancies')
          .select('''
            id,
            unit_id,
            tenant_id,
            status,
            created_at,
            units!inner(
              id,
              property_id,
              rent,
              unit_number,
              properties!inner(
                id,
                title,
                city,
                image_url,
                owner_id
              )
            )
          ''')
          .eq('tenant_id', tenantId);

      final data = response as List<dynamic>;
      print('✅ Loaded ${data.length} requests');

      if (!mounted) return;

      setState(() {
        _dataLoaded = true;
      });
    } catch (e) {
      print('❌ Error loading requests: $e');
      if (!mounted) return;
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 LOADING STATE
    if (!_dataLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              VSpace(16),
              Text('Loading your requests...'),
            ],
          ),
        ),
      );
    }

    // ❌ NOT SIGNED IN
    if (_noUser) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: RentraEmptyState(
          icon: Icons.lock,
          title: 'Please sign in',
          subtitle: 'Sign in to view your tenancy requests',
        ),
      );
    }

    // 📭 NO REQUESTS
    if (_controller.tenantTenancies.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: RentraEmptyState(
          icon: Icons.inbox,
          title: 'No requests yet',
          subtitle: 'Browse properties and send requests to get started',
        ),
      );
    }

    // ✅ REQUESTS LIST
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.tenantTenancies.length,
        itemBuilder: (_, index) {
          final tenancy = _controller.tenantTenancies[index] as dynamic;
          return _buildRequestCard(tenancy);
        },
      ),
    );
  }

  Widget _buildRequestCard(dynamic tenancy) {
    final status = tenancy['status'] as String;
    final statusColor = _getStatusColor(status);
    final unit = tenancy['units'] as Map;
    final property = unit['properties'] as Map;
    final createdAt = DateTime.parse(tenancy['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              // 🏠 PROPERTY IMAGE & INFO
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property['image_url'] as String,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: RentraColors.background,
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const VSpace(12),

              // 🏘️ PROPERTY NAME & LOCATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RentraColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const VSpace(4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: RentraColors.lightText),
                            const HSpace(4),
                            Text(
                              property['city'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: RentraColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const HSpace(12),
                  RentraStatusBadge(
                    label: status,
                    status: status,
                    icon: _getStatusIcon(status),
                  ),
                ],
              ),
              const VSpace(12),

              // 📋 REQUEST DETAILS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RentraColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem('Unit', unit['unit_number'] as String),
                        Container(
                          height: 30,
                          width: 1,
                          color: RentraColors.divider,
                        ),
                        _buildInfoItem(
                          'Rent',
                          '৳${unit['rent']}',
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: RentraColors.divider,
                        ),
                        _buildInfoItem(
                          'Requested',
                          _formatDate(createdAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const VSpace(12),

              // 📝 STATUS MESSAGE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusMessage(status),
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return RentraColors.success;
      case 'rejected':
        return RentraColors.error;
      case 'pending':
      default:
        return RentraColors.pending;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '✅ Your request has been approved! Check the details above and prepare for tenancy.';
      case 'rejected':
        return '❌ Your request was rejected. Try requesting another unit or contact the owner.';
      case 'pending':
      default:
        return '⏳ Your request is pending. The owner will review it soon.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: RentraColors.lightText,
            ),
          ),
          const VSpace(4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: RentraColors.darkText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}