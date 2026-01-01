// import 'package:flutter/material.dart';
// import 'package:rentra/Application/unit_controller.dart';
// import 'package:rentra/core/models/property.dart';
// import 'package:rentra/UI/Screens/add_unit_screen.dart';
// import 'package:rentra/Application/role_controller.dart';

// class UnitListScreen extends StatefulWidget {
//   final Property property;
//   final UnitController controller;

//   const UnitListScreen({
//     super.key,
//     required this.property,
//     required this.controller,
//   });

//   @override
//   State<UnitListScreen> createState() => _UnitListScreenState();
// }

// class _UnitListScreenState extends State<UnitListScreen> {
  
// final RoleController roleController = RoleController();
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.loadUnits(widget.property.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: widget.controller,
//       builder: (_, __) {
//         if (widget.controller.isLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         return Scaffold(
//           appBar: AppBar(title: Text('Units - ${widget.property.title}')),
//           floatingActionButton: roleController.isOwner
//               ? FloatingActionButton(
//                   child: const Icon(Icons.add),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AddUnitScreen(
//                           propertyId: widget.property.id,
//                           controller: widget.controller,
//                         ),
//                       ),
//                     );
//                   },
//                 )
//               : null,
//           body: ListView.builder(
//             itemCount: widget.controller.units.length,
//             itemBuilder: (_, index) {
//               final unit = widget.controller.units[index];

//               return ListTile(
//                 title: Text('Unit ${unit.unitNumber}'),
//                 subtitle: Text('Rent: ৳${unit.rent}'),
//                 trailing: Switch(
//                   value: unit.isAvailable,
//                   onChanged: (_) {
//                     widget.controller.toggleAvailability(unit);
//                   },
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:rentra/Application/unit_controller.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/UI/Screens/add_unit_screen.dart';
import 'package:rentra/Application/role_controller.dart';
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
  final RoleController _roleController = RoleController();
  bool _isOwner = false;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadOwnerStatus();
    widget.controller.loadUnits(widget.property.id);
  }

  Future<void> _loadOwnerStatus() async {
    try {
      final user = SupabaseManager.supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _loadingRole = false);
        return;
      }

      final role = await _roleController.loadRole(user.id);
      if (!mounted) return;
      
      setState(() {
        _isOwner = role == 'owner';
        _loadingRole = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRole = false);
      debugPrint('Error loading role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        if (widget.controller.isLoading || _loadingRole) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Units - ${widget.property.title}')),
          floatingActionButton: _isOwner
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
                      trailing: Switch(
                        value: unit.isAvailable,
                        onChanged: (_) {
                          widget.controller.toggleAvailability(unit);
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}