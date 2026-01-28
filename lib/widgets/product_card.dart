import 'package:flutter/material.dart';
import '../models/product.dart';
import 'rating_widget.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image - Fixed height based on constraints
                Container(
                  height: constraints.maxWidth * 0.6, // Adjust ratio for smaller screens
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        product.images.isNotEmpty
                            ? product.images.first
                            : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: product.hasDiscount
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${product.discountPercent.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),

                // Product Info - Fixed height with SingleChildScrollView
                SizedBox(
                  height: constraints.maxWidth * 0.8, // Adjusted for smaller screens
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product Name and Details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Reduced font size
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Company and Color
                              Text(
                                '${product.company} • ${product.color}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 10, // Reduced font size
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Type Badge
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 80, // Limit badge width
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.type,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9, // Reduced font size
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Rating - Fixed size
                          SizedBox(
                            height: 16, // Fixed height for rating
                            child: Row(
                              children: [
                                RatingWidget(
                                  rating: product.rating,
                                  ratingCount: product.ratingCount,
                                  size: 12, // Smaller rating stars
                                  showLabel: false,
                                ),
                                if (product.ratingCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      product.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 10, // Smaller font
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Price and Add to Cart - Compact layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Price Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.hasDiscount)
                                      Text(
                                        product.formattedPrice,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 10, // Smaller font
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      product.formattedFinalPrice,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12, // Smaller font
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Add to Cart Button - Smaller and more compact
                              if (product.hasStock)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  child: IconButton(
                                    onPressed: onAddToCart,
                                    icon: Icon(
                                      Icons.shopping_cart,
                                      color: theme.colorScheme.primary,
                                      size: 16, // Smaller icon
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                    style: IconButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Stock Badge - Only show if needed
                          if (product.totalStock > 0 && product.totalStock <= 10)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: product.totalStock <= 5
                                    ? Colors.orange[50]
                                    : Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: product.totalStock <= 5
                                      ? Colors.orange
                                      : Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 8, // Smaller icon
                                    color: product.totalStock <= 5
                                        ? Colors.orange[800]
                                        : Colors.green[800],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.totalStock} left',
                                    style: TextStyle(
                                      fontSize: 8, // Smaller font
                                      color: product.totalStock <= 5
                                          ? Colors.orange[800]
                                          : Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}