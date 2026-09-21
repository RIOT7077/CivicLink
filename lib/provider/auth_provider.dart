import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  String? role;

 Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    await _authService.login(context, email, password);
    notifyListeners();
  }


  Future<void> register(String name, String email, String password,String phone) async {
    user = await _authService.register(name, email, password, phone);
    role = 'citizen';
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    role = null;
    notifyListeners();
  }
}
