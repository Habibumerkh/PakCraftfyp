// ignore_for_file: empty_catches
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/add_product_screen.dart';
import 'package:pakcraft/screens/cart.dart';
import 'package:pakcraft/widgets/smart_image.dart';
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
  final Color bgColor = const Color(0xFFE0DCD3); // Beige
  final Color primaryDark = const Color(0xFF3B281D); // Deep Brown
  final Color actionOrange = const Color(0xFFFF7F11); // Orange

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
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: actionOrange,
                onRefresh: () async {
                  await _fetchProducts();
                  await _fetchFavoriteIds();
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Pakcraft",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: primaryDark,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: actionOrange),
                  const SizedBox(width: 6),
                  Text(
                    "Hi, ${currentUser!.user_name.split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: primaryDark.withOpacity(0.5), size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Search handcrafted items...",
                  style: TextStyle(color: Colors.black38, fontSize: 15),
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
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                path,
                height: 28,
                width: 28,
                color: primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Featured Items",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 15),
          _products.isEmpty
              ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(color: actionOrange),
                  ),
                )
              : GestureDetector(
                  onTap: () => _openDetail(_products[0]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        SmartImage(
                          _getFixedImageUrl(_products[0]['image_path']),
                          width: double.infinity,
                          height: 200,
                          borderRadius: 20,
                        ),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: actionOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "TRENDING",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              _products[0]['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Arrivals",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading
              ? Center(child: CircularProgressIndicator(color: actionOrange))
              : AnimationLimiter(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
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
                        duration: const Duration(milliseconds: 400),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () => _openDetail(product),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        SmartImage(
                                          imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          borderRadius: 18,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () => _toggleFavorite(
                                              product['product_id'].toString(),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? Colors.red
                                                    : primaryDark,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: primaryDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Rs. ${product['price']}",
                                            style: TextStyle(
                                              color: actionOrange,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
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
      height: 80,
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, "Home", Colors.white, true, () {}),
          if (!isSeller)
            _navItem(
              Icons.shopping_bag_outlined,
              "Cart",
              Colors.white60,
              false,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const CartScreen()),
              ),
            ),

          if (isSeller) ...[
            _navItem(
              Icons.storefront_rounded,
              "Shop",
              Colors.white60,
              false,
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
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: actionOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: actionOrange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],

          _navItem(
            Icons.favorite_outline_rounded,
            "Favorites",
            Colors.white60,
            false,
            () => Navigator.pushNamed(context, '/favorites'),
          ),

          _navItem(
            Icons.person_outline_rounded,
            "Profile",
            Colors.white60,
            false,
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
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? actionOrange : color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
