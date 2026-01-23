import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _addressController = TextEditingController();
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final addresses = apiService.savedAddresses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anwani Zilizohifadhiwa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Address Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ongeza Anwani Mpya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (!_isAdding)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isAdding = true);
                        },
                        icon: const Icon(Icons.add_location),
                        label: const Text('Ongeza Anwani Mpya'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      )
                    else
                      Column(
                        children: [
                          TextFormField(
                            controller: _addressController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Anwani Kamili',
                              hintText: 'Andika anwani yako kamili...',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tafadhali weka anwani';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() => _isAdding = false);
                                    _addressController.clear();
                                  },
                                  child: const Text('Batilisha'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveAddress,
                                  child: const Text('Hifadhi'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Saved Addresses
            const Text(
              'Anwani Zilizohifadhiwa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            addresses.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Huna anwani zilizohifadhiwa',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bonyeza "Ongeza Anwani Mpya" ili kuanza',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              index == 0 ? Icons.home : Icons.location_on,
                              color: index == 0 ? Colors.blue : Colors.grey,
                            ),
                            title: Text(address),
                            subtitle: index == 0
                                ? const Text('(Anwani yako kuu)')
                                : null,
                            trailing: index > 0
                                ? IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteAddress(index),
                                  )
                                : null,
                            onTap: () {
                              _setAsDefault(address, index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _saveAddress() {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.addAddress(address);
    
    setState(() {
      _isAdding = false;
      _addressController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anwani imehifadhiwa!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ondoa Anwani'),
        content: const Text('Una uhakika unataka kuondoa anwani hii?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batilisha'),
          ),
          ElevatedButton(
            onPressed: () {
              final apiService = Provider.of<ApiService>(context, listen: false);
              apiService.removeAddress(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anwani imeondolewa!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ondoa'),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(String address, int index) {
    if (index == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weka kama Anwani Kuu'),
        content: const Text('Una uhakika unataka kufanya anwani hii kuwa anwani yako kuu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batilisha'),
          ),
          ElevatedButton(
            onPressed: () {
              final apiService = Provider.of<ApiService>(context, listen: false);
              // Move address to first position
              final addresses = apiService.savedAddresses;
              addresses.removeAt(index);
              addresses.insert(0, address);
              // Notify listeners
              apiService.notifyListeners();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anwani imewekwa kama kuu!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Weka'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}