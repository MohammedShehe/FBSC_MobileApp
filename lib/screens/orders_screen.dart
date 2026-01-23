import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import '../widgets/rating_modal.dart';
import '../widgets/cancel_order_modal.dart';
import 'initiate_return_screen.dart';
import 'return_history_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'yote';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    switch (_selectedFilter) {
      case 'imewekwa':
        return allOrders.where((order) => order.status == 'Imewekwa').toList();
      case 'inasafirishwa':
        return allOrders.where((order) => order.status == 'Inasafirishwa').toList();
      case 'imepokelewa':
        return allOrders.where((order) => order.status == 'Imepokelewa').toList();
      case 'ghairishwa':
        return allOrders.where((order) => order.status == 'Ghairishwa').toList();
      case 'kurudishwa':
        return allOrders.where((order) => order.status == 'Kurudishwa').toList();
      default:
        return allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final authService = Provider.of<AuthService>(context);
    final orders = _getFilteredOrders(apiService.orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia ya Maagizo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReturnHistoryScreen(),
                ),
              );
            },
            tooltip: 'Historia ya Kurudisha',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Yote'),
            Tab(text: 'Imewekwa'),
            Tab(text: 'Inasafirishwa'),
            Tab(text: 'Imepokelewa'),
            Tab(text: 'Ghairishwa'),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = ['yote', 'imewekwa', 'inasafirishwa', 'imepokelewa', 'ghairishwa'][index];
            });
          },
        ),
      ),
      body: apiService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Huna maagizo bado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Agizo lako la kwanza litaonekana hapa',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Nenda Kwenye Duka'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (authService.authToken != null) {
                      await apiService.loadOrders(authService.authToken!);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order, context);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agizo #${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.formattedDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: order.statusColor),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: order.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Order Items
            Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              item.product.images.isNotEmpty
                                  ? item.product.images.first
                                  : 'https://via.placeholder.com/100x100?text=Bidhaa',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item.quantity} × ${item.product.formattedFinalPrice}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Saizi: ${item.cleanSize}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.formattedTotalPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
            const Divider(height: 24),
            
            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumla ya Agizo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.formattedTotalPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            if (order.paymentMethod != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Njia ya Malipo: ${order.paymentMethod}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            
            if (order.shippingAddress != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anwani: ${order.shippingAddress}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                if (order.status == 'Imewekwa') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelOrderModal(order);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Batilisha',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                if (order.status == 'Imepokelewa') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InitiateReturnScreen(order: order),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text(
                        'Rudisha',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                if (order.status == 'Imepokelewa') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showRatingModal(order);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: const Text(
                        'Tathmini',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _viewOrderDetails(context, order);
                    },
                    child: const Text('Maelezo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingModal(Order order) {
    showDialog(
      context: context,
      builder: (context) => RatingModal(orderId: order.id),
    );
  }

  void _showCancelOrderModal(Order order) {
    showDialog(
      context: context,
      builder: (context) => CancelOrderModal(orderId: order.id),
    );
  }

  void _viewOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Draggable handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Maelezo ya Agizo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Status Timeline
                      _buildOrderTimeline(order),
                      
                      const SizedBox(height: 24),
                      
                      // Order Items
                      const Text(
                        'Bidhaa zilizoagizwa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ...order.items.map((item) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        item.product.images.isNotEmpty
                                            ? item.product.images.first
                                            : 'https://via.placeholder.com/100x100?text=Bidhaa',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity} × ${item.product.formattedFinalPrice}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'Saizi: ${item.cleanSize}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.formattedTotalPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 24),
                      
                      // Order Summary
                      const Text(
                        'Muhtasari wa Agizo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildSummaryRow('Jumla ya Bidhaa:', '${order.items.length}'),
                              _buildSummaryRow('Jumla ya Bei:', order.formattedTotalPrice),
                              if (order.paymentMethod != null)
                                _buildSummaryRow('Njia ya Malipo:', order.paymentMethod!),
                              if (order.shippingAddress != null)
                                _buildSummaryRow('Anwani:', order.shippingAddress!),
                              if (order.customerNotes != null)
                                _buildSummaryRow('Maelezo ya Ziada:', order.customerNotes!),
                              const Divider(height: 24),
                              _buildSummaryRow(
                                'JUMLA:',
                                order.formattedTotalPrice,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTimeline(Order order) {
    final steps = [
      {'title': 'Imewekwa', 'date': order.createdAt},
      {'title': 'Inasindika', 'date': order.createdAt.add(const Duration(hours: 1))},
      {'title': 'Inasafirishwa', 'date': order.createdAt.add(const Duration(days: 1))},
      {'title': 'Imewasilishwa', 'date': order.createdAt.add(const Duration(days: 2))},
    ];

    int currentStep = 0;
    switch (order.status) {
      case 'Imewekwa':
        currentStep = 0;
        break;
      case 'Inasindika':
        currentStep = 1;
        break;
      case 'Inasafirishwa':
        currentStep = 2;
        break;
      case 'Imepokelewa':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hatua za Agizo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Column(
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= currentStep;
            final isCurrent = index == currentStep;
            
            return Row(
              children: [
                // Step Indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    border: isCurrent ? Border.all(color: Colors.green, width: 3) : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Step Line (except for last step)
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < currentStep ? Colors.green : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  )
                else
                  const SizedBox(width: 8),
                
                // Step Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted ? Colors.green : Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDate(step['date'] as DateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? null : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.green : null,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}