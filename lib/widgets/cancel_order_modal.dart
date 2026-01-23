import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CancelOrderModal extends StatefulWidget {
  final int orderId;
  
  const CancelOrderModal({super.key, required this.orderId});

  @override
  _CancelOrderModalState createState() => _CancelOrderModalState();
}

class _CancelOrderModalState extends State<CancelOrderModal> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, String>> _reasons = [
    {'value': 'Nimebadilisha nia', 'label': 'Nimebadilisha nia'},
    {'value': 'Bei sio sahihi', 'label': 'Bei sio sahihi'},
    {'value': 'Muda wa usafirishaji mrefu', 'label': 'Muda wa usafirishaji mrefu'},
    {'value': 'Nyingine', 'label': 'Nyingine'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Batilisha Agizo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reason Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chagua Sababu ya Kughairi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  ..._reasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason['label']!),
                      value: reason['value']!,
                      groupValue: _selectedReason,
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Details
              TextField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Maelezo Zaidi (Inahitajika)',
                  hintText: 'Tafadhali andika sababu ya kughairi agizo hili...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agizo linaweza kughairiwa tu ikiwa bado halijaanza kusafirishwa.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batilisha'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _selectedReason != null && _detailsController.text.isNotEmpty
                                ? _cancelOrder
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Thibitisha Kughairi'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Call API to cancel order
      // This would be implemented when API endpoint is available
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agizo limeghairiwa kikamilifu.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Update orders list
      await apiService.loadOrders(authService.authToken!);
      
      Navigator.of(context).pop();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}