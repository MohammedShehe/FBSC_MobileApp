import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RatingModal extends StatefulWidget {
  final int orderId;
  
  const RatingModal({super.key, required this.orderId});

  @override
  _RatingModalState createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _packageRating = 0;
  int _deliveryRating = 0;
  int _productRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final Map<int, String> _ratingComments = {
    1: "Mbaya sana",
    2: "Mbaya",
    3: "Wastani",
    4: "Nzuri",
    5: "Bora kabisa",
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Icon(Icons.star, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Tathmini Uzoefu Wako',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shiriki maoni yako na tusaidie kuboresha huduma zetu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
              
              // Package Rating
              _buildRatingSection(
                title: 'Tathmini ya Kifurushi',
                rating: _packageRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _packageRating = rating;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Delivery Rating
              _buildRatingSection(
                title: 'Tathmini ya Usafirishaji',
                rating: _deliveryRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _deliveryRating = rating;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Product Rating
              _buildRatingSection(
                title: 'Tathmini ya Bidhaa',
                rating: _productRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _productRating = rating;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Comment
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Maoni Yako (Hiari)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _submitRating,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Wasilisha Tathmini Yako',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Stars
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    onRatingChanged(index + 1);
                  },
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: index < rating ? Colors.amber : Colors.grey[300],
                  ),
                );
              }),
            ),
            
            // Rating Value
            Text(
              '$rating',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Rating Comment
        Text(
          rating > 0 ? _ratingComments[rating]! : 'Bonyeza nyota kuweka tathmini',
          style: TextStyle(
            color: rating > 0 ? Colors.grey[800] : Colors.grey[500],
            fontStyle: rating > 0 ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    if (_packageRating == 0 || _deliveryRating == 0 || _productRating == 0) {
      setState(() {
        _errorMessage = 'Tafadhali tathmini vipengele vyote vitatu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.submitRating(
        authService.authToken!,
        widget.orderId,
        _packageRating,
        _deliveryRating,
        _productRating,
        _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asante kwa tathmini yako! Maoni yako yanatusaidia kuboresha huduma zetu.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Hitilafu katika kuwasilisha tathmini';
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
    _commentController.dispose();
    super.dispose();
  }
}