import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? user;
  bool isLoading = false;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final loggedUser = await ApiService().login(email, password);
      user = loggedUser;

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password, String phone, String city) async {
    try {
      isLoading = true;
      notifyListeners();

      final success = await ApiService().registerUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        city: city,
      );

      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    user = null;
    notifyListeners();
  }
}
