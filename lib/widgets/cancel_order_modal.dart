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
  String? _errorMessage;

  final List<Map<String, String>> _reasons = [
    {'value': 'changed_mind', 'label': 'Nimebadilisha nia'},
    {'value': 'wrong_price', 'label': 'Bei sio sahihi'},
    {'value': 'delivery_time', 'label': 'Muda wa usafirishaji mrefu'},
    {'value': 'found_cheaper', 'label': 'Nimepata bei nafuu mahali pengine'},
    {'value': 'other', 'label': 'Nyingine'},
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
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
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
                      onPressed: _isLoading ? null : () {
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
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.cancelOrder(
        authService.authToken!,
        widget.orderId,
        _selectedReason!,
        _detailsController.text,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agizo limeghairiwa kikamilifu.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Update orders list
        await apiService.loadOrders(authService.authToken!);
        
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Hitilafu katika kughairi agizo';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hitilafu ya mtandao: $e';
      });
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