import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/models/user_profile.dart';
import 'package:rentra/core/supabase_client.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

class OwnerTenancyRequestsScreen extends StatefulWidget {
  final TenancyController controller;

  const OwnerTenancyRequestsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<OwnerTenancyRequestsScreen> createState() =>
      _OwnerTenancyRequestsScreenState();
}

class _OwnerTenancyRequestsScreenState
    extends State<OwnerTenancyRequestsScreen> {
  bool _noUser = false;
  bool _actionInProgress = false;

  // ✅ FIXED: Changed from Map<String, dynamic>? to UserProfile?
  final Map<String, UserProfile?> _tenantProfiles = {};

  @override
  void initState() {
    super.initState();

    final user = SupabaseManager.supabase.auth.currentUser;
    if (user == null) {
      _noUser = true;
      return;
    }

    widget.controller.loadPendingForOwner(user.id);
  }

  // ───────────────────────── PROFILE LOADING (SAFE) ──────────────────────────

  Future<void> _ensureTenantProfile(String tenantId) async {
    if (_tenantProfiles.containsKey(tenantId)) return;

    try {
      final profile =
          await AppDependencies.profileRepository.getProfileById(tenantId);
      if (mounted) {
        setState(() => _tenantProfiles[tenantId] = profile);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _tenantProfiles[tenantId] = null);
      }
    }
  }

  // ────────────────────────────────── UI ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pending Requests'),
            centerTitle: true,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_noUser) {
      return const RentraEmptyState(
        icon: Icons.lock,
        title: 'Please sign in',
        subtitle: 'Sign in to view tenancy requests',
      );
    }

    if (widget.controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            VSpace(16),
            Text('Loading requests...'),
          ],
        ),
      );
    }

    if (widget.controller.pendingTenancies.isEmpty) {
      return const RentraEmptyState(
        icon: Icons.inbox,
        title: 'No pending requests',
        subtitle: 'Tenants will appear here when they request units',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = SupabaseManager.supabase.auth.currentUser;
        if (user != null) {
          await widget.controller.loadPendingForOwner(user.id);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.controller.pendingTenancies.length,
        itemBuilder: (_, index) {
          final req = widget.controller.pendingTenancies[index];
          _ensureTenantProfile(req.tenantId);
          return _buildRequestCard(req);
        },
      ),
    );
  }

  // ───────────────────────────── REQUEST CARD ────────────────────────────────

  Widget _buildRequestCard(dynamic req) {
    final tenant = _tenantProfiles[req.tenantId];
    
    // ✅ FIXED: Now using UserProfile properties instead of Map access
    final tenantName = tenant?.fullName ?? tenant?.email.split('@').first ?? 'Loading...';
    final tenantEmail = tenant?.email ?? 'Loading...';
    final tenantPhone = tenant?.phone ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 TENANT INFO
            _TenantHeader(
              name: tenantName,
              email: tenantEmail,
              phone: tenantPhone,
            ),

            const VSpace(16),

            Text(
              'Unit Details',
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
                    value: _formatDate(req.startDate ?? DateTime.now()),
                  ),
                ],
              ),
            ),

            const VSpace(16),

            Center(
              child: RentraStatusBadge(
                label: req.status,
                status: req.status,
                icon: Icons.schedule,
              ),
            ),

            const VSpace(16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _actionInProgress
                        ? null
                        : () => _handleAction(
                              approve: true,
                              reqId: req.id,
                              unitId: req.unitId,
                              tenantName: tenantName,
                            ),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RentraColors.success,
                    ),
                  ),
                ),
                const HSpace(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _actionInProgress
                        ? null
                        : () => _handleAction(
                              approve: false,
                              reqId: req.id,
                              tenantName: tenantName,
                            ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RentraColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── ACTION HANDLING ─────────────────────────────

  Future<void> _handleAction({
    required bool approve,
    required int reqId,
    int? unitId,
    required String tenantName,
  }) async {
    final confirmed = await _showConfirmDialog(
      title: approve ? 'Approve Request?' : 'Reject Request?',
      message: approve
          ? 'Approve tenancy request from $tenantName?'
          : 'Reject tenancy request from $tenantName?',
    );

    if (!confirmed) return;

    setState(() => _actionInProgress = true);

    if (approve) {
      await widget.controller.approve(reqId, unitId!);
    } else {
      await widget.controller.reject(reqId);
    }

    if (!mounted) return;

    setState(() => _actionInProgress = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve ? '✅ Request approved' : '❌ Request rejected',
        ),
        backgroundColor:
            approve ? RentraColors.success : RentraColors.error,
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ───────────────────────────── HELPERS ─────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ───────────────────────── TENANT HEADER WIDGET ─────────────────────────────

class _TenantHeader extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const _TenantHeader({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RentraColors.limeGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          const VSpace(4),
          Text(email, style: Theme.of(context).textTheme.bodySmall),
          const VSpace(8),
          Row(
            children: [
              const Icon(Icons.phone, size: 14),
              const HSpace(8),
              Text(phone),
            ],
          ),
        ],
      ),
    );
  }
}