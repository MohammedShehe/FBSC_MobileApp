import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => _cartItems;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get discount => itemCount >= 3 ? subtotal * 0.1 : 0;
  double get total => subtotal - discount;
  
  String get formattedSubtotal => 'TZS ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  String get formattedDiscount => 'TZS ${discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  String get formattedTotal => 'TZS ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  
  void addToCart(Product product, int quantity, String size) {
    final cleanSize = size.replaceAll(RegExp(r'EU', caseSensitive: false), '').trim();
    
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.cleanSize == cleanSize
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        size: size,
      ));
    }
    notifyListeners();
  }
  
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity = newQuantity;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getOrderItems() {
    return _cartItems.map((item) {
      final size = item.product.sizes.firstWhere(
        (s) => s.cleanSize == item.cleanSize,
        orElse: () => ProductSize(code: item.size, sizeLabel: item.size, stock: 0),
      );
      
      return {
        'product_id': item.product.id,
        'size_id': size.id,
        'quantity': item.quantity,
      };
    }).toList();
  }
}