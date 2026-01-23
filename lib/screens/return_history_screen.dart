import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReturnHistoryScreen extends StatefulWidget {
  const ReturnHistoryScreen({super.key});

  @override
  _ReturnHistoryScreenState createState() => _ReturnHistoryScreenState();
}

class _ReturnHistoryScreenState extends State<ReturnHistoryScreen> {
  List<dynamic> _returns = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await apiService.getReturnHistory(authService.authToken!);
      
      if (result['success']) {
        setState(() {
          _returns = result['data']['returns'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hitilafu ya mtandao: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia ya Kurudisha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReturns,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadReturns,
                        child: const Text('Jaribu Tena'),
                      ),
                    ],
                  ),
                )
              : _returns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory, size: 100, color: Colors.grey),
                          const SizedBox(height: 20),
                          const Text(
                            'Huna historia ya kurudisha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ombi lako la kwanza la kurudisha litaonekana hapa',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Nenda kwenye Maagizo'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReturns,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _returns.length,
                        itemBuilder: (context, index) {
                          final returnItem = _returns[index];
                          return _buildReturnCard(returnItem);
                        },
                      ),
                    ),
    );
  }

  Widget _buildReturnCard(Map<String, dynamic> returnItem) {
    final status = returnItem['status'] ?? 'in_review';
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final createdAt = DateTime.parse(returnItem['created_at'] ?? DateTime.now().toString());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Return Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kurudisha #${returnItem['id']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tarehe: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Order Info
            if (returnItem['order_id'] != null)
              Text(
                'Agizo #${returnItem['order_id']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            
            if (returnItem['reason'] != null) ...[
              const SizedBox(height: 8),
              Text('Sababu: ${_getReasonText(returnItem['reason'])}'),
            ],
            
            if (returnItem['details'] != null) ...[
              const SizedBox(height: 8),
              Text('Maelezo: ${returnItem['details']}'),
            ],
            
            // Products
            if (returnItem['products'] != null && returnItem['products'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Bidhaa Zilizorudishwa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(returnItem['products'] as List).map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${product['name'] ?? 'Bidhaa'}'),
                );
              }).toList(),
            ],
            
            // Resolution
            if (returnItem['resolution'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uamuzi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(returnItem['resolution']),
                    if (returnItem['resolution_date'] != null)
                      Text(
                        'Tarehe: ${DateTime.parse(returnItem['resolution_date']).day}/${DateTime.parse(returnItem['resolution_date']).month}/${DateTime.parse(returnItem['resolution_date']).year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'in_review':
        return 'Inakaguliwa';
      case 'approved':
        return 'Imekubaliwa';
      case 'rejected':
        return 'Imekataliwa';
      case 'processed':
        return 'Imesindika';
      case 'completed':
        return 'Imekamilika';
      default:
        return 'Inakaguliwa';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'processed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'size':
        return 'Saizi haifai';
      case 'color':
        return 'Rangi si sahihi';
      case 'damaged':
        return 'Bidhaa imeharibika';
      case 'wrong':
        return 'Bidhaa nyingine tofauti';
      case 'quality':
        return 'Ubora wa chini';
      case 'other':
        return 'Nyingine';
      default:
        return reason;
    }
  }
}