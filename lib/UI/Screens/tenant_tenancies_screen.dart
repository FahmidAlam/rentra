import 'package:flutter/material.dart';
import 'package:rentra/Application/tenancy_controller.dart';
import 'package:rentra/core/app_dependencies.dart';
import 'package:rentra/core/supabase_client.dart';

class TenantTenanciesScreen extends StatefulWidget {
  const TenantTenanciesScreen({super.key});

  @override
  State<TenantTenanciesScreen> createState() => _TenantTenanciesScreenState();
}

class _TenantTenanciesScreenState extends State<TenantTenanciesScreen> {
  late final TenancyController _controller;
  bool _noUser = false;

  @override
  void initState() {
    super.initState();
    _controller = AppDependencies.tenancyController;
    
    final currentUser = SupabaseManager.supabase.auth.currentUser;
    if (currentUser == null) {
      _noUser = true;
      return;
    }
    
    // Load tenant's own tenancy requests
    _loadTenantTenancies(currentUser.id);
  }

  Future<void> _loadTenantTenancies(String tenantId) async {
    try {
      print('🔄 Loading tenancies for tenant: $tenantId');
      
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
      print('✅ Loaded ${data.length} tenancies for tenant');
      
      // Convert to Tenancy objects with property info
      _controller.tenantTenancies = data.map((json) {
        try {
          return _parseTenantTenancy(json);
        } catch (e) {
          print('❌ Error parsing tenancy: $e');
          return null;
        }
      }).whereType<TenantTenancyInfo>().toList();
      
      _controller.notifyListeners();
    } catch (e) {
      print('❌ Error loading tenant tenancies: $e');
    }
  }

  TenantTenancyInfo _parseTenantTenancy(Map<String, dynamic> json) {
    final unit = json['units'] as Map<String, dynamic>;
    final property = unit['properties'] as Map<String, dynamic>;
    
    return TenantTenancyInfo(
      id: json['id'] as int,
      unitId: json['unit_id'] as int,
      propertyTitle: property['title'] as String,
      propertyCity: property['city'] as String,
      propertyImage: property['image_url'] as String,
      unitNumber: unit['unit_number'] as String,
      rent: (unit['rent'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        //  LOADING STATE
        if (_controller.isLoading) {
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
                  SizedBox(height: 16),
                  Text('Loading your requests...'),
                ],
              ),
            ),
          );
        }

        //  NOT SIGNED IN
        if (_noUser) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Requests'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Please sign in to view your requests',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        //  NO REQUESTS
        if (_controller.tenantTenancies.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Requests'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tenancy requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Browse properties and request units to see them here',
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
              final tenancy = _controller.tenantTenancies[index];
              return _buildTenancyCard(tenancy);
            },
          ),
        );
      },
    );
  }

  //  BUILD TENANCY CARD
  Widget _buildTenancyCard(TenantTenancyInfo tenancy) {
    final statusColor = _getStatusColor(tenancy.status);
    final statusIcon = _getStatusIcon(tenancy.status);

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
              //  PROPERTY IMAGE & INFO
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  tenancy.propertyImage,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //  PROPERTY NAME & LOCATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenancy.propertyTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              tenancy.propertyCity,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  //  STATUS BADGE
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          tenancy.status.toUpperCase(),
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

              const SizedBox(height: 12),

              // UNIT & RENT INFO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('Unit', tenancy.unitNumber),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildInfoItem('Rent', '৳${tenancy.rent.toStringAsFixed(0)}'),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildInfoItem(
                      'Requested',
                      _formatDate(tenancy.createdAt),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              //  STATUS MESSAGE
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
                  _getStatusMessage(tenancy.status),
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

  //  GET STATUS COLOR
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  //  GET STATUS ICON
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

  //  GET STATUS MESSAGE
  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '✅ Your request has been approved! Contact the owner for next steps.';
      case 'rejected':
        return '❌ Your request was rejected. Try requesting another unit.';
      case 'pending':
      default:
        return '⏳ Waiting for owner response. They will review your request soon.';
    }
  }

  //  FORMAT DATE
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  //  BUILD INFO ITEM
  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

//  MODEL FOR TENANT TENANCY INFO
class TenantTenancyInfo {
  final int id;
  final int unitId;
  final String propertyTitle;
  final String propertyCity;
  final String propertyImage;
  final String unitNumber;
  final double rent;
  final String status;
  final DateTime createdAt;

  TenantTenancyInfo({
    required this.id,
    required this.unitId,
    required this.propertyTitle,
    required this.propertyCity,
    required this.propertyImage,
    required this.unitNumber,
    required this.rent,
    required this.status,
    required this.createdAt,
  });
}