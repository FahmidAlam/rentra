import "package:rentra/Application/auth_controller.dart";

class RoleController {
  final AuthController _authController = AuthController();
  String? _role;
  Future<String?> loadRole(String userId) async{
    _role ??= await _authController.fetchUserRole(userId);
    return _role;
  }
  bool get isOwner => _role =='owner';
  bool get isRenter => _role == 'renter';
}