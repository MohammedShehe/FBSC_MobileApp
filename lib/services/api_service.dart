import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';
import '../models/order.dart';

class ApiService extends ChangeNotifier {
  final String baseUrl = 'https://api.fourbrothers.online/api/customers';
  
  List<Product> _products = [];
  List<Product> get products => _products;
  
  List<dynamic> _ads = [];
  List<dynamic> get ads => _ads;
  
  String? _announcement;
  String? get announcement => _announcement;
  
  List<Order> _orders = [];
  List<Order> get orders => _orders;
  
  List<String> _savedAddresses = [];
  List<String> get savedAddresses => _savedAddresses;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadInitialData(String? token) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Don't wait for all at once, load sequentially
      await loadProducts();
      
      // Try to load ads and announcement, but don't fail if they don't work
      try {
        await loadAds();
      } catch (e) {
        print('Error loading ads: $e');
      }
      
      try {
        await loadAnnouncement(token);
      } catch (e) {
        print('Error loading announcement: $e');
      }
      
      if (token != null) {
        try {
          await loadOrders(token);
        } catch (e) {
          print('Error loading orders: $e');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
      
      // If API fails, load sample data
      if (_products.isEmpty) {
        _products = getSampleProducts();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _products = (data as List).map((product) => Product.fromJson(product)).toList();
        notifyListeners();
      } else {
        print('Failed to load products: ${response.statusCode}');
        _products = getSampleProducts();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading products: $e');
      _products = getSampleProducts();
      notifyListeners();
    }
  }
  
  Future<void> loadAds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ads'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _ads = data['ads'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading ads: $e');
      // Don't fail if ads don't load
    }
  }
  
  Future<void> loadAnnouncement(String? token) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/announcements'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _announcement = data['announcement'];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading announcement: $e');
      // Don't fail if announcement doesn't load
    }
  }
  
  Future<void> loadOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _orders = (data['orders'] as List).map((order) => Order.fromJson(order, _products)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading orders: $e');
    }
  }


// In api_service.dart, add these methods:
Future<void> loadAddresses(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/addresses'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _savedAddresses = List<String>.from(data['addresses'] ?? []);
      notifyListeners();
    }
  } catch (e) {
    print('Error loading addresses: $e');
    // Load sample addresses if API fails
    _savedAddresses = [
      'Mikocheni B, Dar es Salaam',
      'Kijitonyama, Dar es Salaam',
      'Sinza, Dar es Salaam'
    ];
    notifyListeners();
  }
}

Future<Map<String, dynamic>> saveAddress(String token, String address) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'address': address}),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      addAddress(address);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Failed to save address'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}
  
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> placeOrder(String token, List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'items': items}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Order placement failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Profile update failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> changePassword(String token, String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Password change failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  void addAddress(String address) {
    if (!_savedAddresses.contains(address)) {
      _savedAddresses.add(address);
      notifyListeners();
    }
  }
  
  void removeAddress(int index) {
    if (index < _savedAddresses.length && index > 0) {
      _savedAddresses.removeAt(index);
      notifyListeners();
    }
  }

  // Add these methods to your ApiService class in api_service.dart

Future<Map<String, dynamic>> verifyIdentity(String firstName, String lastName) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-identity'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Verification failed'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> resetPassword(String firstName, String lastName, String newPassword) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'new_password': newPassword,
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> resetMobile(String firstName, String lastName, String newMobile) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-mobile'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'new_mobile': newMobile,
      }),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Mobile reset failed'};
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}
  
  List<Product> getSampleProducts() {
    return [
      Product(
        id: 1,
        name: "Viatu vya Kukimbia Nike Air Max",
        company: "Nike",
        color: "Nyeusi/Nyeupe",
        type: "Njumu na Trainer",
        price: 150000,
        discountPercent: 17,
        finalPrice: 124500,
        totalStock: 15,
        description: "Viatu vya kukimbia vya Nike Air Max vilivyoundwa kwa ustadi.",
        images: ["https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop"],
        sizes: [
          ProductSize(id: 1, code: "M", sizeLabel: "Medium", stock: 5),
          ProductSize(id: 2, code: "L", sizeLabel: "Large", stock: 5),
          ProductSize(id: 3, code: "XL", sizeLabel: "Extra Large", stock: 5),
        ],
        createdAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: "Viatu vya Mpira Adidas Predator",
        company: "Adidas",
        color: "Njano/Nyeusi",
        type: "Viatu vya Mpira",
        price: 180000,
        discountPercent: 20,
        finalPrice: 144000,
        totalStock: 8,
        description: "Viatu bora vya mpira kwa wachezaji wa kitaalam.",
        images: ["https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&h=400&fit=crop"],
        sizes: [
          ProductSize(id: 4, code: "38", sizeLabel: "38", stock: 3),
          ProductSize(id: 5, code: "40", sizeLabel: "40", stock: 3),
          ProductSize(id: 6, code: "42", sizeLabel: "42", stock: 2),
        ],
        createdAt: DateTime.now(),
      ),
      Product(
        id: 3,
        name: "Viatu vya Kawaida Puma Classic",
        company: "Puma",
        color: "Nyeupe",
        type: "Viatu vya Kawaida",
        price: 95000,
        discountPercent: 10,
        finalPrice: 85500,
        totalStock: 12,
        description: "Viatu vizuri vya kila siku kwa starehe kubwa.",
        images: ["https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=400&fit=crop"],
        sizes: [
          ProductSize(id: 7, code: "39", sizeLabel: "39", stock: 4),
          ProductSize(id: 8, code: "41", sizeLabel: "41", stock: 4),
          ProductSize(id: 9, code: "43", sizeLabel: "43", stock: 4),
        ],
        createdAt: DateTime.now(),
      ),
      Product(
        id: 4,
        name: "Viatu vya Miti Under Armour",
        company: "Under Armour",
        color: "Kijivu",
        type: "Viatu vya Miti",
        price: 120000,
        discountPercent: 15,
        finalPrice: 102000,
        totalStock: 6,
        description: "Viatu vya miti vilivyoundwa kwa matumizi magumu.",
        images: ["https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400&h=400&fit=crop"],
        sizes: [
          ProductSize(id: 10, code: "40", sizeLabel: "40", stock: 2),
          ProductSize(id: 11, code: "42", sizeLabel: "42", stock: 2),
          ProductSize(id: 12, code: "44", sizeLabel: "44", stock: 2),
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
}