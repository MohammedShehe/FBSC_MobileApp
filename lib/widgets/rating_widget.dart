import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double size;
  final bool showLabel;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.ratingCount,
    this.size = 20,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, color: Colors.amber, size: size);
            } else if (index < rating.ceil()) {
              return Icon(Icons.star_half, color: Colors.amber, size: size);
            } else {
              return Icon(Icons.star_border, color: Colors.grey, size: size);
            }
          }),
        ),
        
        const SizedBox(width: 4),
        
        // Rating Text
        if (showLabel)
          Text(
            '($ratingCount tathmini)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey,
            ),
          )
        else if (ratingCount > 0)
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}