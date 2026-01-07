// import 'package:flutter/material.dart';
// import 'package:rentra/Application/tenancy_controller.dart';
// import 'package:rentra/core/app_dependencies.dart';
// import 'package:rentra/core/supabase_client.dart';
// import 'package:rentra/core/theme/app_theme.dart';
// import 'package:rentra/UI/widgets/reusable_widgets.dart';

// class OwnerTenancyRequestsScreen extends StatefulWidget {
//   final TenancyController controller;

//   const OwnerTenancyRequestsScreen({super.key, required this.controller});

//   @override
//   State<OwnerTenancyRequestsScreen> createState() =>
//       _OwnerTenancyRequestsScreenState();
// }

// class _OwnerTenancyRequestsScreenState
//     extends State<OwnerTenancyRequestsScreen> {
//   bool _noUser = false;
//   final Map<String, Map<String, dynamic>?> _tenantProfiles = {};

//   @override
//   void initState() {
//     super.initState();

//     final currentUser = SupabaseManager.supabase.auth.currentUser;
//     if (currentUser == null) {
//       _noUser = true;
//       return;
//     }

//     widget.controller.loadPendingForOwner(currentUser.id);
//   }

//   // ✅ REFACTORED: Use repository instead of direct Supabase call
//   Future<void> _loadTenantProfile(String tenantId) async {
//     if (_tenantProfiles.containsKey(tenantId)) {
//       return; // Already loaded
//     }

//     try {
//       final profile = await AppDependencies.profileRepository.getProfileById(tenantId);
//       if (mounted) {
//         setState(() {
//           _tenantProfiles[tenantId] = profile;
//         });
//       }
//     } catch (e) {
//       print('❌ Error loading tenant profile: $e');
//       if (mounted) {
//         setState(() {
//           _tenantProfiles[tenantId] = null;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: widget.controller,
//       builder: (_, __) {
//         // 🔄 LOADING STATE
//         if (widget.controller.isLoading) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Pending Requests'),
//               centerTitle: true,
//             ),
//             body: const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   VSpace(16),
//                   Text('Loading requests...'),
//                 ],
//               ),
//             ),
//           );
//         }

//         // ❌ NOT SIGNED IN
//         if (_noUser) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Pending Requests'),
//               centerTitle: true,
//             ),
//             body: RentraEmptyState(
//               icon: Icons.lock,
//               title: 'Please sign in',
//               subtitle: 'Sign in to view tenancy requests',
//             ),
//           );
//         }

//         // 📭 NO REQUESTS
//         if (widget.controller.pendingTenancies.isEmpty) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Pending Requests'),
//               centerTitle: true,
//             ),
//             body: RentraEmptyState(
//               icon: Icons.inbox,
//               title: 'No pending requests',
//               subtitle: 'Tenants will appear here when they request units',
//             ),
//           );
//         }

//         // ✅ REQUESTS LIST
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Pending Requests'),
//             centerTitle: true,
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//           ),
//           body: RefreshIndicator(
//             onRefresh: () async {
//               final user = SupabaseManager.supabase.auth.currentUser;
//               if (user != null) {
//                 await widget.controller.loadPendingForOwner(user.id);
//               }
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: widget.controller.pendingTenancies.length,
//               itemBuilder: (_, index) {
//                 final req = widget.controller.pendingTenancies[index];
//                 return _buildRequestCard(req);
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRequestCard(dynamic req) {
//     // Load tenant profile asynchronously
//     _loadTenantProfile(req.tenantId);

//     final tenantInfo = _tenantProfiles[req.tenantId];
//     final tenantEmail = tenantInfo?['email'] ?? 'Loading...';
//     final tenantName = tenantInfo?['full_name'] ?? 'Loading...';
//     final tenantPhone = tenantInfo?['phone'] ?? 'N/A';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border(
//             left: BorderSide(
//               color: RentraColors.pending,
//               width: 4,
//             ),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 👤 TENANT INFO HEADER
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: RentraColors.limeGreen.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: RentraColors.limeGreen.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: RentraColors.limeGreen,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.person,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                         const HSpace(12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 tenantName,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: RentraColors.darkText,
//                                 ),
//                               ),
//                               const VSpace(2),
//                               Text(
//                                 tenantEmail,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: RentraColors.lightText,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const VSpace(12),
//                     Divider(
//                       color: RentraColors.limeGreen.withOpacity(0.3),
//                       height: 1,
//                     ),
//                     const VSpace(12),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.phone,
//                           size: 14,
//                           color: RentraColors.darkTeal,
//                         ),
//                         const HSpace(8),
//                         Text(
//                           tenantPhone,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: RentraColors.darkText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const VSpace(16),

//               // 🏠 UNIT & PROPERTY INFO
//               Text(
//                 'Property Unit Details',
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               const VSpace(8),

//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: RentraColors.background,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     RentraInfoRow(
//                       icon: Icons.domain,
//                       label: 'Unit ID',
//                       value: req.unitId.toString(),
//                     ),
//                     const VSpace(12),
//                     RentraInfoRow(
//                       icon: Icons.calendar_month,
//                       label: 'Requested On',
//                       value: _formatDate(req.startDate ?? DateTime.now()),
//                     ),
//                     const VSpace(12),
//                     RentraInfoRow(
//                       icon: Icons.schedule,
//                       label: 'Status',
//                       value: req.status.toUpperCase(),
//                     ),
//                   ],
//                 ),
//               ),

//               const VSpace(16),

//               // ⏳ STATUS BADGE
//               Center(
//                 child: RentraStatusBadge(
//                   label: req.status,
//                   status: req.status,
//                   icon: Icons.schedule,
//                 ),
//               ),

//               const VSpace(16),

//               // 🔘 ACTION BUTTONS
//               Row(
//                 children: [
//                   // ✅ APPROVE BUTTON
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _showConfirmDialog(
//                         context,
//                         title: 'Approve Request?',
//                         message: 'Approve tenancy request from $tenantName?',
//                         onConfirm: () async {
//                           await widget.controller.approve(req.id, req.unitId);
//                           if (!context.mounted) return;
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('✅ Request approved'),
//                               backgroundColor: RentraColors.success,
//                             ),
//                           );
//                         },
//                       ),
//                       icon: const Icon(Icons.check),
//                       label: const Text('Approve'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: RentraColors.success,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const HSpace(12),
//                   // ❌ REJECT BUTTON
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _showConfirmDialog(
//                         context,
//                         title: 'Reject Request?',
//                         message: 'Reject tenancy request from $tenantName?',
//                         onConfirm: () async {
//                           await widget.controller.reject(req.id);
//                           if (!context.mounted) return;
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('❌ Request rejected'),
//                               backgroundColor: RentraColors.error,
//                             ),
//                           );
//                         },
//                       ),
//                       icon: const Icon(Icons.close),
//                       label: const Text('Reject'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: RentraColors.error,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showConfirmDialog(
//     BuildContext context, {
//     required String title,
//     required String message,
//     required VoidCallback onConfirm,
//   }) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: onConfirm,
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day} ${_monthName(date.month)} ${date.year}';
//   }

//   String _monthName(int month) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return months[month - 1];
//   }
// }
import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
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

  final Map<String, Map<String, dynamic>?> _tenantProfiles = {};

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
    final tenantName = tenant?['full_name'] ?? 'Loading...';
    final tenantEmail = tenant?['email'] ?? 'Loading...';
    final tenantPhone = tenant?['phone'] ?? 'N/A';

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
