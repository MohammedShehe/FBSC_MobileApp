import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';

class InitiateReturnScreen extends StatefulWidget {
  final Order order;
  
  const InitiateReturnScreen({super.key, required this.order});

  @override
  _InitiateReturnScreenState createState() => _InitiateReturnScreenState();
}

class _InitiateReturnScreenState extends State<InitiateReturnScreen> {
  final List<String> _selectedItems = [];
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _reasons = [
    {'value': 'size', 'label': 'Saizi haifai'},
    {'value': 'color', 'label': 'Rangi si sahihi'},
    {'value': 'damaged', 'label': 'Bidhaa imeharibika'},
    {'value': 'wrong', 'label': 'Bidhaa nyingine tofauti'},
    {'value': 'quality', 'label': 'Ubora wa chini'},
    {'value': 'other', 'label': 'Nyingine'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurudisha Bidhaa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Column(
                children: [
                  Icon(Icons.undo, size: 60, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Kurudisha Bidhaa',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Taja bidhaa unazotaka kurudisha',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Order Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agizo #${widget.order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Tarehe: ${widget.order.formattedDate}'),
                    Text('Jumla: ${widget.order.formattedTotalPrice}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Select Items to Return
            const Text(
              'Chagua Bidhaa za Kurudisha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...widget.order.items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Saizi: ${item.cleanSize} • ${item.formattedTotalPrice}'),
                  secondary: Container(
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
                  value: _selectedItems.contains(item.product.id.toString()),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedItems.add(item.product.id.toString());
                      } else {
                        _selectedItems.remove(item.product.id.toString());
                      }
                    });
                  },
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Reason Selection
            const Text(
              'Sababu ya Kurudisha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            
            const SizedBox(height: 24),
            
            // Details
            const Text(
              'Maelezo Zaidi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Eleza kwa kina sababu ya kurudisha bidhaa...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Requirements
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Muhimu Kabla ya Kurudisha:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildListItem('Bidhaa lazima iwe kwenye kifurushi chake asili'),
                  _buildListItem('Lebo na vitambulisho vimeachwa'),
                  _buildListItem('Bidhaa haijatumika au kuvaa'),
                  _buildListItem('Hakuna uharibifu wowote'),
                ],
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
            
            const SizedBox(height: 32),
            
            // Submit Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _selectedItems.isEmpty || _selectedReason == null || _detailsController.text.isEmpty
                          ? null
                          : _submitReturn,
                      icon: const Icon(Icons.send),
                      label: const Text(
                        'Wasilisha Ombi la Kurudisha',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReturn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.initiateReturn(
        authService.authToken!,
        widget.order.id,
        _selectedReason!,
        _detailsController.text,
        _selectedItems,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ombi la kurudisha limewasilishwa! Tutawasiliana nawe.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Hitilafu katika kuwasilisha ombi la kurudisha';
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