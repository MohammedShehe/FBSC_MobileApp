import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 1;
  String? _selectedAddress;
  bool _showNewAddressForm = false;
  final TextEditingController _newAddressController = TextEditingController();
  bool _isLoading = false;
  bool _isFirstOrder = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfFirstOrder();
  }

  void _checkIfFirstOrder() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    // Check if user has previous orders
    if (apiService.orders.isNotEmpty) {
      setState(() {
        _isFirstOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final authService = Provider.of<AuthService>(context);
    final apiService = Provider.of<ApiService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Malipo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Checkout Progress
            _buildCheckoutProgress(),
            
            const SizedBox(height: 20),
            
            // Step 1: Address Selection
            if (_currentStep == 1) _buildStep1(apiService),
            
            // Step 2: Order Summary
            if (_currentStep == 2) _buildStep2(cartService),
            
            // Step 3: Payment
            if (_currentStep == 3) _buildStep3(cartService, authService),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProgressStep(1, 'Anwani', _currentStep >= 1),
          Container(
            height: 2,
            width: 40,
            color: _currentStep >= 2 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
          ),
          _buildProgressStep(2, 'Muhtasari', _currentStep >= 2),
          Container(
            height: 2,
            width: 40,
            color: _currentStep >= 3 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
          ),
          _buildProgressStep(3, 'Malipo', _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.blue : (Colors.grey[300] ?? Colors.grey),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(ApiService apiService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chagua Anwani ya Mshipisho',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Saved Addresses
        if (apiService.savedAddresses.isEmpty)
          const Text(
            'Huna anwani zilizohifadhiwa. Tafadhali ongeza anwani mpya.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: apiService.savedAddresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Radio<String>(
                    value: address,
                    groupValue: _selectedAddress,
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                  ),
                  title: Text(address),
                  subtitle: index == 0 ? const Text('(Anwani yako kuu)') : null,
                  onTap: () {
                    setState(() {
                      _selectedAddress = address;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        
        const SizedBox(height: 16),
        
        // Add New Address Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showNewAddressForm = true;
            });
          },
          icon: const Icon(Icons.add_location),
          label: const Text('Ongeza Anwani Mpya'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
          ),
        ),
        
        // New Address Form
        if (_showNewAddressForm)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50] ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300] ?? Colors.grey.shade300),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _newAddressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Anwani Mpya Kamili',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showNewAddressForm = false;
                            _newAddressController.clear();
                          });
                        },
                        child: const Text('Batilisha'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final address = _newAddressController.text.trim();
                          if (address.isNotEmpty) {
                            // Save address to API
                            final result = await apiService.saveAddress(
                              Provider.of<AuthService>(context, listen: false).authToken!,
                              address,
                            );
                            
                            if (result['success']) {
                              setState(() {
                                _selectedAddress = address;
                                _showNewAddressForm = false;
                                _newAddressController.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Anwani mpya imehifadhiwa!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Hifadhi Anwani Mpya'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Continue Button
        if (_selectedAddress != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
              child: const Text('Endelea kwa Muhtasari'),
            ),
          ),
      ],
    );
  }

  Widget _buildStep2(CartService cartService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Muhtasari wa Agizo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Order Items
                Column(
                  children: cartService.cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item.quantity} × ${item.product.formattedFinalPrice}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.formattedTotalPrice,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const Divider(height: 24),
                
                // Order Summary
                _buildSummaryRow('Jumla ya Bidhaa:', '${cartService.itemCount} '),
                _buildSummaryRow('Jumla ya Bei:', cartService.formattedSubtotal),
                _buildSummaryRow('Usafirishaji:', 'TZS 0'),
                _buildSummaryRow('Punguzo:', cartService.formattedDiscount),
                const Divider(height: 24),
                _buildSummaryRow(
                  'JUMLA:',
                  cartService.formattedTotal,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Delivery Estimation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Makadirio ya Uwasilishaji',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Utapokea Bidhaa Hii: ${_calculateDeliveryDate()}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Proceed to Payment Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 3;
              });
            },
            child: const Text('Endelea kwa Malipo'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(CartService cartService, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Malipo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Malipo yanafanyika kwa pesa taslimu (COD) unapopokea bidhaa.',
                  style: TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 20),
                
                // Password Verification for First Order
                if (_isFirstOrder) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: const Text(
                            'Kwa ajili ya usalama, tafadhali ingiza nenosiri lako kuthibitisha agizo lako la kwanza.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nenosiri lako',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Show forgot password dialog
                      },
                      child: const Text('Umesahau nenosiri?'),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Confirm Order Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isFirstOrder && _passwordController.text.isEmpty
                        ? null
                        : () {
                            _confirmOrder(cartService, authService);
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Thibitisha Agizo',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 20 : 16,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDeliveryDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 5));
    final days = ['Jumapili', 'Jumatatu', 'Jumanne', 'Jumatano', 'Alhamisi', 'Ijumaa', 'Jumamosi'];
    return days[deliveryDate.weekday];
  }

  Future<void> _confirmOrder(CartService cartService, AuthService authService) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali chagua anwani ya mshipisho.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      // For first order, verify password
      if (_isFirstOrder) {
        // Verify password logic here
      }

      // Place order
      final orderItems = cartService.getOrderItems();
      final result = await apiService.placeOrder(
        authService.authToken!,
        orderItems,
      );

      if (result['success']) {
        // Show success animation
        _showSuccessAnimation();
        
        // Clear cart
        cartService.clearCart();
        
        // Update order status
        await apiService.loadOrders(authService.authToken!);
        
        // Update first order status
        setState(() {
          _isFirstOrder = false;
        });
        
        // Navigate back
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hitilafu katika kuweka agizo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu ya mtandao: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Agizo Limefanikiwa!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ahsante kwa ununuzi wako. Tutawasiliana nawe kuhusu mshipisho.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Endelea na Ununuzi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}