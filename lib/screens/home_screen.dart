// ignore_for_file: deprecated_member_use, use_build_context_synchronously, empty_catches

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // ANIMATION PACKAGE
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/add_product_screen.dart';
import 'package:pakcraft/screens/cart.dart';
import 'package:pakcraft/widgets/smart_image.dart'; // IMPORT SMART IMAGE
import 'product_detail_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;
  bool get isSeller => currentUser?.role == 'seller';

  List _products = [];
  List<String> _favoriteIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchProducts();
  }

  Future<void> _loadUserInfo() async {
    User? user = await RemUSer.readUSerInfo();
    if (mounted) setState(() => currentUser = user);
    if (user != null) _fetchFavoriteIds();
  }

  Future<void> _fetchProducts() async {
    try {
      var res = await http.get(Uri.parse(API.getProducts));
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _products = json.decode(res.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFavoriteIds() async {
    try {
      var res = await http.post(
        Uri.parse(API.getFavorite),
        body: {"user_id": currentUser!.user_id.toString()},
      );
      if (res.statusCode == 200) {
        List favs = json.decode(res.body);
        if (mounted) {
          setState(() {
            _favoriteIds = favs.map((e) => e['product_id'].toString()).toList();
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _toggleFavorite(String productId) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }
    setState(() {
      _favoriteIds.contains(productId)
          ? _favoriteIds.remove(productId)
          : _favoriteIds.add(productId);
    });
    try {
      await http.post(
        Uri.parse(API.toggleFavorite),
        body: {
          "user_id": currentUser!.user_id.toString(),
          "product_id": productId,
        },
      );
    } catch (e) {}
  }

  String _getFixedImageUrl(String dbPath) {
    String fixedPath = dbPath.replaceAll('\\', '/');
    return "${API.hostConnect}/$fixedPath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A3D2B),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchProducts();
                  await _fetchFavoriteIds();
                },
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(), // Smooth bounce effect
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildCategories(),
                      _buildFeaturedSection(),
                      _buildProductGrid(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // --- BROKEN DOWN WIDGETS FOR CLEANER CODE ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Pakcraft",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: isSeller ? const Color(0xFFFF7F11) : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Hi, ${currentUser!.user_name.split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search handcrafted items...",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _categoryIcon("assets/logos/jewelry.png", "Jewelry"),
          _categoryIcon("assets/logos/pottery.png", "Pottery"),
          _categoryIcon("assets/logos/textile.png", "Textile"),
          _categoryIcon("assets/logos/rug.png", "Rugs"),
        ],
      ),
    );
  }

  Widget _categoryIcon(String path, String label) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) =>
              CategoryScreen(categoryName: label, categoryIcon: path),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: Image.asset(
                path,
                height: 26,
                width: 26,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Featured",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _products.isEmpty
              ? Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white10,
                  ),
                  child: const Center(
                    child: Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => _openDetail(_products[0]),
                  child: Stack(
                    children: [
                      // OPTIMIZED IMAGE
                      SmartImage(
                        _getFixedImageUrl(_products[0]['image_path']),
                        width: double.infinity,
                        height: 180,
                        borderRadius: 14,
                      ),

                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7F11),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Trending",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                          ),
                          child: Text(
                            _products[0]['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Products",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : AnimationLimiter(
                  // ADDS SMOOTH ANIMATION
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70, // Taller cards
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      var product = _products[index];
                      String imageUrl = _getFixedImageUrl(
                        product['image_path'],
                      );
                      bool isFav = _favoriteIds.contains(
                        product['product_id'].toString(),
                      );

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () => _openDetail(product),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE
                                    Stack(
                                      children: [
                                        // OPTIMIZED IMAGE
                                        SmartImage(
                                          imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          borderRadius: 12,
                                          fit: BoxFit.cover,
                                        ),

                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => _toggleFavorite(
                                              product['product_id'].toString(),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? Colors.red
                                                    : Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // TEXT
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Rs. ${product['price']}",
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 12,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "4.8",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  void _openDetail(Map product) {
    String imageUrl = _getFixedImageUrl(product['image_path']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ProductDetailScreen(
          product: {
            ...product,
            'image': imageUrl,
            'rating': 4.5,
            'reviews': 10,
            'material': 'Mixed',
            'seller': 'Handmade Store',
            'dimensions': 'Standard',
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: const Color(0xFF3B281D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", Colors.white, () {}),
          if (!isSeller)
            _navItem(
              Icons.shopping_cart_outlined,
              "Cart",
              Colors.white70,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const CartScreen()),
              ),
            ),
          if (isSeller) ...[
            _navItem(
              Icons.storefront,
              "Shop",
              Colors.white70,
              () => Navigator.pushNamed(context, '/shop'),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddProductScreen()),
                );
                _fetchProducts();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7F11),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 26),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Add",
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
          _navItem(
            Icons.favorite_border,
            "Favorites",
            Colors.white70,
            () => Navigator.pushNamed(context, '/favorites'),
          ),
          _navItem(
            Icons.person_outline,
            "Profile",
            Colors.white70,
            () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
