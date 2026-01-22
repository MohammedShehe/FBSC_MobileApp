import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../models/product.dart';
import '../widgets/rating_widget.dart';
import '../widgets/share_widget.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedQuantity = 1;
  String? _selectedSize;
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first.cleanSize;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali chagua saizi ya bidhaa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final selectedSize = widget.product.sizes.firstWhere(
      (s) => s.cleanSize == _selectedSize,
      orElse: () => widget.product.sizes.first,
    );
    
    if ((selectedSize.stock ?? 0) < _selectedQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Samahani, kuna akiba ya ${selectedSize.stock} tu kwa saizi $_selectedSize.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    cartService.addToCart(widget.product, _selectedQuantity, _selectedSize!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} (Saizi: $_selectedSize) imeongezwa kwenye karatasi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.product.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  if (widget.product.hasDiscount)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ShareWidget.showShareDialog(
                    context,
                    product: widget.product,
                  );
                },
              ),
            ],
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RatingWidget(
                          rating: widget.product.rating,
                          ratingCount: widget.product.ratingCount,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Company and Color
                    Text(
                      '${widget.product.company} • ${widget.product.color}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Price
                    Row(
                      children: [
                        if (widget.product.hasDiscount)
                          Text(
                            widget.product.formattedPrice,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.formattedFinalPrice,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stock Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.product.hasStock
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.product.hasStock
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        widget.product.hasStock
                            ? 'Akiba (${widget.product.totalStock})'
                            : 'Hakuna Akiba',
                        style: TextStyle(
                          color: widget.product.hasStock
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      'Maelezo ya Bidhaa',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description.isNotEmpty
                          ? widget.product.description
                          : 'Bidhaa haina maelezo ya ziada.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Size Selection
                    Text(
                      'Chagua Saizi (EU)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.product.sizes.map((size) {
                        final isSelected = _selectedSize == size.cleanSize;
                        final hasStock = (size.stock ?? 0) > 0;
                        
                        return FilterChip(
                          label: Text(
                            size.cleanSize,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: hasStock
                              ? (selected) {
                                  if (selected) {
                                    setState(() => _selectedSize = size.cleanSize);
                                  }
                                }
                              : null,
                          backgroundColor: hasStock
                              ? (isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.grey[200])
                              : Colors.grey[100],
                          selectedColor: theme.colorScheme.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (hasStock ? Colors.black : Colors.grey),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (hasStock ? Colors.grey[300]! : Colors.grey[200]!),
                            ),
                          ),
                          avatar: hasStock
                              ? Text(
                                  '${size.stock}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey,
                                  ),
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      'Nambari ndani ya mabano inaonyesha idadi ya akiba kwa kila saizi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quantity Selection
                    Row(
                      children: [
                        Text(
                          'Idadi:',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _selectedQuantity > 1
                                    ? () {
                                        setState(() => _selectedQuantity--);
                                      }
                                    : null,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_selectedQuantity',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (_selectedSize != null) {
                                    final selectedSize = widget.product.sizes.firstWhere(
                                      (s) => s.cleanSize == _selectedSize,
                                      orElse: () => widget.product.sizes.first,
                                    );
                                    
                                    if (_selectedQuantity < (selectedSize.stock ?? 0)) {
                                      setState(() => _selectedQuantity++);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Samahani, kuna akiba ya ${selectedSize.stock} tu kwa saizi $_selectedSize.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    setState(() => _selectedQuantity++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Delivery Estimation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
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
                                Text(
                                  'Makadirio ya Uwasilishaji',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Utapokea Bidhaa Hii: Jumamosi ijayo',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text(
                          'Weka kwenye Karatasi',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Maelezo Zaidi'),
                        Tab(text: 'Tathmini'),
                      ],
                    ),
                    
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Details Tab
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Maelezo ya Ziada',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(1),
                                      1: FlexColumnWidth(2),
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          const Text('Chapa:',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(widget.product.company),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Rangi:',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(widget.product.color),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Aina:',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(widget.product.type),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Ukubwa:',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(widget.product.sizes
                                              .map((s) => s.cleanSize)
                                              .join(', ')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Reviews Tab
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tathmini za Wateja',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                RatingWidget(
                                  rating: widget.product.rating,
                                  ratingCount: widget.product.ratingCount,
                                  showLabel: true,
                                ),
                                const SizedBox(height: 16),
                                if (widget.product.ratingCount == 0)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info, color: Colors.blue[800]),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Bado hakuna tathmini za bidhaa hii. Kuwa wa kwanza kutathmini!',
                                            style: TextStyle(color: Colors.blue[800]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ShareWidget.showShareDialog(context, product: widget.product);
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}