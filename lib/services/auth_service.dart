import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  String? _refreshToken;
  bool _isFirstOrder = true;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;
  bool get isFirstOrder => _isFirstOrder;

  AuthService() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    _refreshToken = prefs.getString('refreshToken');
    
    if (_authToken != null) {
      final userData = prefs.getString('userData');
      if (userData != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(userData);
          _currentUser = User.fromJson(data);
        } catch (e) {
          if (kDebugMode) {
            print('Error loading user data: $e');
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> login(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();
    
    _currentUser = User.fromJson(responseData['customer']);
    _authToken = responseData['accessToken'];
    _refreshToken = responseData['refreshToken'];
    _isFirstOrder = true;
    
    await prefs.setString('authToken', _authToken!);
    await prefs.setString('refreshToken', _refreshToken!);
    await prefs.setString('userData', jsonEncode(responseData['customer']));
    
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userData');
    
    _currentUser = null;
    _authToken = null;
    _refreshToken = null;
    _isFirstOrder = true;
    
    notifyListeners();
  }

  void updateFirstOrderStatus(bool value) {
    _isFirstOrder = value;
    notifyListeners();
  }

  void updateUserProfile(User user) {
    _currentUser = user;
    _saveUserData();
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode({
        'id': _currentUser!.id,
        'first_name': _currentUser!.firstName,
        'last_name': _currentUser!.lastName,
        'phone': _currentUser!.phone,
        'email': _currentUser!.email,
        'address': _currentUser!.address,
        'gender': _currentUser!.gender,
      }));
    }
  }
}