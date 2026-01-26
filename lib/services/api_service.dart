import 'dart:convert';
import 'dart:async';
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
  
  bool _usingLocalData = false;
  bool get usingLocalData => _usingLocalData;
  
  Future<void> loadInitialData(String? token) async {
    _isLoading = true;
    _usingLocalData = false;
    notifyListeners();
    
    try {
      await loadProducts();
      
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
          await loadAddresses(token);
        } catch (e) {
          print('Error loading user data: $e');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
      
      // Fallback to local data
      if (_products.isEmpty) {
        await _loadLocalProducts();
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
        _usingLocalData = false;
        notifyListeners();
      } else {
        await _loadLocalProducts();
      }
    } catch (e) {
      print('Network error loading products: $e');
      await _loadLocalProducts();
    }
  }
  
  Future<void> _loadLocalProducts() async {
    try {
      _usingLocalData = true;
      _products = await _getLocalProducts();
      notifyListeners();
      print('Loaded ${_products.length} local products');
    } catch (e) {
      print('Error loading local products: $e');
      _products = getSampleProducts();
      notifyListeners();
    }
  }
  
  Future<List<Product>> _getLocalProducts() async {
    final products = <Product>[];
    
    try {
      // Load local product data
      final localProducts = [
        {
          'id': 1,
          'name': 'Nike Mercurial Superfly 9 Elite',
          'company': 'Nike',
          'color': 'Volt/Black',
          'type': 'Soccer Cleats',
          'price': 350000,
          'discount_percent': 15,
          'final_price': 297500,
          'total_stock': 8,
          'description': 'Premium soccer cleats for professional players. Features Flyknit construction and All Conditions Control technology.',
          'images': ['assets/products/Mercurial1.JPEG', 'assets/products/Mercurial2.JPEG'],
          'sizes': [
            {'code': '40', 'size_label': '40', 'stock': 2},
            {'code': '41', 'size_label': '41', 'stock': 3},
            {'code': '42', 'size_label': '42', 'stock': 2},
            {'code': '43', 'size_label': '43', 'stock': 1},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.8,
          'total_ratings': 24
        },
        {
          'id': 2,
          'name': 'Nike Air Zoom Pegasus 39',
          'company': 'Nike',
          'color': 'White/Blue',
          'type': 'Running Shoes',
          'price': 180000,
          'discount_percent': 10,
          'final_price': 162000,
          'total_stock': 12,
          'description': 'Versatile running shoes with responsive cushioning. Perfect for daily training and long-distance running.',
          'images': ['assets/products/AirZoom.JPEG'],
          'sizes': [
            {'code': '39', 'size_label': '39', 'stock': 4},
            {'code': '40', 'size_label': '40', 'stock': 4},
            {'code': '41', 'size_label': '41', 'stock': 4},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.5,
          'total_ratings': 18
        },
        {
          'id': 3,
          'name': 'Nike Air Max 270',
          'company': 'Nike',
          'color': 'Black/White',
          'type': 'Lifestyle',
          'price': 220000,
          'discount_percent': 20,
          'final_price': 176000,
          'total_stock': 6,
          'description': 'Comfortable lifestyle shoes with visible Air cushioning. Great for casual wear and light activities.',
          'images': ['assets/products/Nike1.JPEG', 'assets/products/Nike2.JPEG'],
          'sizes': [
            {'code': '38', 'size_label': '38', 'stock': 2},
            {'code': '40', 'size_label': '40', 'stock': 2},
            {'code': '42', 'size_label': '42', 'stock': 2},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.7,
          'total_ratings': 32
        },
        {
          'id': 4,
          'name': 'Adidas Predator Accuracy',
          'company': 'Adidas',
          'color': 'White/Red',
          'type': 'Soccer Cleats',
          'price': 320000,
          'discount_percent': 12,
          'final_price': 281600,
          'total_stock': 5,
          'description': 'Professional soccer cleats with precision engineering for accurate passing and shooting.',
          'images': ['https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&h=400&fit=crop'],
          'sizes': [
            {'code': '39', 'size_label': '39', 'stock': 1},
            {'code': '41', 'size_label': '41', 'stock': 2},
            {'code': '43', 'size_label': '43', 'stock': 2},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.6,
          'total_ratings': 19
        },
        {
          'id': 5,
          'name': 'Puma Future Ultimate',
          'company': 'Puma',
          'color': 'Blue/Orange',
          'type': 'Soccer Cleats',
          'price': 280000,
          'discount_percent': 18,
          'final_price': 229600,
          'total_stock': 7,
          'description': 'Agile soccer cleats with adaptive FUZIONFIT+ compression band for lockdown fit.',
          'images': ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=400&fit=crop'],
          'sizes': [
            {'code': '40', 'size_label': '40', 'stock': 3},
            {'code': '42', 'size_label': '42', 'stock': 2},
            {'code': '44', 'size_label': '44', 'stock': 2},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.4,
          'total_ratings': 15
        },
        {
          'id': 6,
          'name': 'New Balance Fresh Foam 1080',
          'company': 'New Balance',
          'color': 'Grey/Green',
          'type': 'Running Shoes',
          'price': 190000,
          'discount_percent': 8,
          'final_price': 174800,
          'total_stock': 9,
          'description': 'Premium running shoes with plush Fresh Foam midsole for maximum comfort during long runs.',
          'images': ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop'],
          'sizes': [
            {'code': '38', 'size_label': '38', 'stock': 3},
            {'code': '40', 'size_label': '40', 'stock': 3},
            {'code': '42', 'size_label': '42', 'stock': 3},
          ],
          'created_at': DateTime.now().toString(),
          'avg_rating': 4.3,
          'total_ratings': 21
        },
      ];
      
      for (var productData in localProducts) {
        try {
          final product = Product.fromJson(productData);
          products.add(product);
        } catch (e) {
          print('Error parsing product: $e');
        }
      }
    } catch (e) {
      print('Error loading local product data: $e');
    }
    
    return products;
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
      } else {
        // Fallback ads
        _ads = [
          {'id': 1, 'image_url': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&h=400&fit=crop', 'title': 'End of Season Sale', 'description': 'Up to 50% off on selected items'},
          {'id': 2, 'image_url': 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800&h=400&fit=crop', 'title': 'New Arrivals', 'description': 'Latest sports shoes available now'},
          {'id': 3, 'image_url': 'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=800&h=400&fit=crop', 'title': 'Free Delivery', 'description': 'Free shipping on orders above TZS 200,000'},
        ];
      }
      notifyListeners();
    } catch (e) {
      print('Error loading ads, using fallback: $e');
      _ads = [
        {'id': 1, 'image_url': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&h=400&fit=crop', 'title': 'End of Season Sale', 'description': 'Up to 50% off on selected items'},
        {'id': 2, 'image_url': 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800&h=400&fit=crop', 'title': 'New Arrivals', 'description': 'Latest sports shoes available now'},
        {'id': 3, 'image_url': 'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=800&h=400&fit=crop', 'title': 'Free Delivery', 'description': 'Free shipping on orders above TZS 200,000'},
      ];
      notifyListeners();
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
      } else {
        _announcement = 'Karibu kwenye Four Brothers Sports Center. Tuna ofa maalum kwa wateja wetu!';
      }
      notifyListeners();
    } catch (e) {
      print('Error loading announcement: $e');
      _announcement = 'Karibu kwenye Four Brothers Sports Center. Tuna ofa maalum kwa wateja wetu!';
      notifyListeners();
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
        return {'success': false, 'message': data['message'] ?? 'Imeshindikana kuhifadhi anwan'};
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
        return {'success': false, 'message': data['message'] ?? 'Imeshindikana kuingia'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      // Check if terms agreed
      if (!(userData['agree_terms'] ?? false)) {
        return {'success': false, 'message': 'You must agree to the terms and conditions'};
      }
      
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
        return {'success': false, 'message': data['message'] ?? 'Usajili umeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> placeOrder(String token, List<Map<String, dynamic>> items, 
      {String? shippingAddress, String? password, bool isFirstOrder = false}) async {
    try {
      final Map<String, dynamic> body = {
        'items': items,
        'shipping_address': shippingAddress,
      };
      
      if (isFirstOrder && password != null) {
        body['first_order_password'] = password;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Malipo ya agizo yameshindikana'};
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
        return {'success': false, 'message': data['message'] ?? 'Kusasisha wasifu kumeshindikana'};
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
        return {'success': false, 'message': data['message'] ?? 'Kubadilisha nenosiri kumeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> changePhoneNumber(String token, String newPhone, 
      String currentPassword, String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-phone'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'new_phone': newPhone,
          'current_password': currentPassword,
          'first_name': firstName,
          'last_name': lastName,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Kubadilisha namba ya simu kumeshindikana'};
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
        return {'success': false, 'message': 'Imeshindikana kutoka'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // FORGOT PASSWORD SYSTEM
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
        return {'success': false, 'message': data['message'] ?? 'Imeshindikana kuthibitisha'};
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
        return {'success': false, 'message': data['message'] ?? 'Kurekebisha nenosiri kumeshindikana'};
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
        return {'success': false, 'message': data['message'] ?? 'Kuweka upya simu kumeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // ORDER MANAGEMENT
  Future<Map<String, dynamic>> cancelOrder(String token, int orderId, String reason, String details) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
          'details': details,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Kughairisha oda kumeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> submitRating(String token, int orderId, 
      int packageRating, int deliveryRating, int productRating, String? comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/rate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'package_rating': packageRating,
          'delivery_rating': deliveryRating,
          'product_rating': productRating,
          'comment': comment,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Kutoa alama kumeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // RETURN SYSTEM
  Future<Map<String, dynamic>> initiateReturn(String token, int orderId, String reason, 
      String details, List<String> productIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/return'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
          'details': details,
          'product_ids': productIds,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Kuanza kurudisha kumeshindikana'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> getReturnHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/returns'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Imeshindikana kupakia historia ya kurudisha'};
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
  
  List<Product> getSampleProducts() {
    return _products.isNotEmpty ? _products : [
      Product(
        id: 1,
        name: "Viatu vya Kukimbia Nike Air Max",
        company: "Nike",
        color: "Nyeusi/Nyeupe",
        type: "Running Shoes",
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
        type: "Soccer Cleats",
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
        type: "Casual Shoes",
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
        type: "Hiking Shoes",
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