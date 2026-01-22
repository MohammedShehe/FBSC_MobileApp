import 'package:flutter/material.dart';
import 'cart.dart';
import 'product.dart';

class Order {
  final int id;
  final List<CartItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? customerNotes;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.shippingAddress,
    this.paymentMethod,
    this.customerNotes,
  });

  factory Order.fromJson(Map<String, dynamic> json, List<Product> products) {
    final items = (json['items'] as List? ?? []).map((item) {
      final productId = item['product_id'];
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: 0,
          name: 'Unknown Product',
          company: '',
          color: '',
          type: '',
          price: 0,
          discountPercent: 0,
          finalPrice: 0,
          totalStock: 0,
          description: '',
          images: [],
          sizes: [],
          createdAt: DateTime.now(),
        ),
      );

      return CartItem(
        product: product,
        quantity: item['quantity'] ?? 1,
        size: item['size'] ?? 'M',
      );
    }).toList();

    return Order(
      id: json['id'] ?? 0,
      items: items,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'Imewekwa',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      customerNotes: json['customer_notes'],
    );
  }

  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTotalPrice => 'TZS ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  String get statusText {
    switch (status) {
      case 'Imewekwa':
        return 'Imewekwa';
      case 'Inasafirishwa':
        return 'Inasafirishwa';
      case 'Imepokelewa':
        return 'Imepokelewa';
      case 'Ghairishwa':
        return 'Ghairishwa';
      case 'Kurudishwa':
        return 'Kurudishwa';
      default:
        return 'Imewekwa';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Imewekwa':
        return Colors.blue;
      case 'Inasafirishwa':
        return Colors.orange;
      case 'Imepokelewa':
        return Colors.green;
      case 'Ghairishwa':
        return Colors.red;
      case 'Kurudishwa':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}