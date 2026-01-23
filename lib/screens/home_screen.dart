import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/theme_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = Provider.of<ApiService>(context, listen: false).products;
  }

  void _onSearch(String query) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = apiService.products;
      });
    } else {
      setState(() {
        _filteredProducts = apiService.products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              (product.company.toLowerCase().contains(query.toLowerCase())) ||
              (product.color.toLowerCase().contains(query.toLowerCase())) ||
              (product.type.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      });
    }
  }

  void _onItemTapped(int index) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (index == 2 && !authService.isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final cartService = Provider.of<CartService>(context);
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);

    final screens = [
      _buildHomeContent(apiService),
      const CartScreen(),
      authService.isAuthenticated ? const AccountScreen() : const LoginScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'FB',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Four Brothers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (authService.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Navigate to admin screen (to be implemented)
              },
            ),
          IconButton(
            icon: Icon(
              themeService.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Nyumbani',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(cartService.itemCount.toString()),
              isLabelVisible: cartService.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Karatasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(authService.isAuthenticated 
                ? Icons.person 
                : Icons.login),
            label: authService.isAuthenticated ? 'Akaunti' : 'Ingia',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent(ApiService apiService) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tafuta bidhaa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Ads Carousel
          if (apiService.ads.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: apiService.ads.length,
                itemBuilder: (context, index) {
                  final ad = apiService.ads[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(ad['image_url'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Announcement
          if (apiService.announcement != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.announcement, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      apiService.announcement!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Products Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 24,
                  width: 4,
                  color: Theme.of(context).primaryColor,
                  margin: const EdgeInsets.only(right: 10),
                ),
                const Text(
                  'Bidhaa Zetu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                onAddToCart: () {
                  final cartService = Provider.of<CartService>(context, listen: false);
                  final authService = Provider.of<AuthService>(context, listen: false);
                  
                  if (!authService.isAuthenticated) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    return;
                  }
                  
                  if (product.hasStock) {
                    cartService.addToCart(product, 1, 'M');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} imeongezwa kwenye karatasi!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Samahani, bidhaa hii hana akiba kwa sasa.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}