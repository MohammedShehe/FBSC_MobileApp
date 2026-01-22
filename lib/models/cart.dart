import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String size;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
  });

  double get totalPrice => (product.finalPrice * quantity);
  String get formattedTotalPrice => 'TZS ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  String get cleanSize => size.replaceAll(RegExp(r'EU', caseSensitive: false), '').trim();

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
      'size': size,
    };
  }
}