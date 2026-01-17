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

  @override
  void initState() {
    super.initState();
    _controller = AppDependencies.tenancyController;

    // Check auth state
    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      setState(() => _noUser = true);
      return;
    }

    // Delegate to controller - NO data fetching here
    _loadData(currentUser.id);

    //  Listen to controller state changes
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  //  Simple controller method call - no business logic
  Future<void> _loadData(String tenantId) async {
    await _controller.loadTenanciesForTenant(tenantId);
  }

  //  Handle controller state changes
  void _onControllerUpdate() {
    if (!mounted) return;

    // Show error if exists
    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _handleRefresh,
          ),
        ),
      );
    }

    // Trigger rebuild
    setState(() {});
  }

  //  Refresh handler
  Future<void> _handleRefresh() async {
    final user = SupabaseManager.supabase.auth.currentUser;
    if (user != null) {
      await _loadData(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOADING STATE
    if (_controller.isLoading && _controller.tenantTenancies.isEmpty) {
      return _buildLoadingState();
    }

    // NOT SIGNED IN
    if (_noUser) {
      return _buildNoUserState();
    }

    // NO REQUESTS
    if (_controller.tenantTenancies.isEmpty) {
      return _buildEmptyState();
    }

    // REQUESTS LIST
    return _buildRequestsList();
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            VSpace(16),
            Text(
              'Loading your requests...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
      ),
      body: RentraEmptyState(
        icon: Icons.lock,
        title: 'Please sign in',
        subtitle: 'Sign in to view your tenancy requests',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: RentraEmptyState(
                icon: Icons.inbox,
                title: 'No requests yet',
                subtitle: 'Browse properties and send requests to get started',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.tenantTenancies.length,
          itemBuilder: (_, index) {
            final tenancy = _controller.tenantTenancies[index] as dynamic;
            return _buildRequestCard(tenancy);
          },
        ),
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
              // PROPERTY IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property['image_url'] as String,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: RentraColors.background,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: RentraColors.background,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
              ),
              const VSpace(12),

              // PROPERTY INFO & STATUS
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const VSpace(4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: RentraColors.lightText,
                            ),
                            const HSpace(4),
                            Expanded(
                              child: Text(
                                property['city'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RentraColors.lightText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

              // UNIT DETAILS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RentraColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      'Unit',
                      unit['unit_number'] as String,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: RentraColors.divider,
                    ),
                    _buildInfoItem(
                      'Rent',
                      '৳${(unit['rent'] as num).toStringAsFixed(0)}',
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
              ),

              const VSpace(12),

              // STATUS MESSAGE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
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
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
