// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/add_product_screen.dart';
import 'package:pakcraft/screens/edit_product_screen.dart';
import 'package:pakcraft/screens/home_screen.dart';
import 'package:pakcraft/screens/favorites_screen.dart';
import 'package:pakcraft/screens/profile_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List _products = [];
  bool _isLoading = true;
  User? currentUser;

  String totalSales = "0";
  String totalOrders = "0";

  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    currentUser = await RemUSer.readUSerInfo();
    setState(() {});
    if (currentUser != null) {
      _fetchMyProducts();
      _fetchSellerStats();
    }
  }

  Future<void> _fetchMyProducts() async {
    try {
      var res = await http.post(
        Uri.parse(API.getSellerProducts),
        body: {"seller_id": currentUser!.user_id.toString()},
      );
      if (res.statusCode == 200) {
        setState(() {
          _products = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSellerStats() async {
    try {
      var res = await http.post(
        Uri.parse(API.getSellerStats),
        body: {"seller_id": currentUser!.user_id.toString()},
      );
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          totalSales = "Rs.${data['revenue']}";
          totalOrders = data['orders'].toString();
        });
      }
    } catch (e) {}
  }

  Future<void> _deleteProduct(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Delete Product",
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
            ),
            content: const Text("Are you sure you want to remove this item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel", style: TextStyle(color: primaryDark)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await http.post(Uri.parse(API.deleteProduct), body: {"product_id": id});
        _fetchMyProducts();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _navigateToEdit(Map<String, dynamic> product) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );
    if (result == true) _fetchMyProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              "My Shop",
              style: TextStyle(
                color: primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            if (currentUser != null && currentUser!.shop_name.isNotEmpty)
              Text(
                currentUser!.shop_name,
                style: TextStyle(
                  color: primaryDark.withOpacity(0.6),
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const HomeScreen()),
                (r) => false,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatCard("Products", "${_products.length}"),
                      const SizedBox(width: 10),
                      _buildStatCard("Orders", totalOrders),
                      const SizedBox(width: 10),
                      _buildStatCard("Sales", totalSales),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Product Catalog",
                    style: TextStyle(
                      color: primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: actionOrange),
                        )
                      : _products.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text("No products uploaded yet."),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            String imageUrl =
                                "${API.hostConnect}/${product['image_path'].toString().replaceAll('\\', '/')}";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product["name"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: primaryDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Stock: ${product['stock_quantity']}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${product['price']}",
                                          style: TextStyle(
                                            color: actionOrange,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: primaryDark,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _navigateToEdit(product),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => _deleteProduct(
                                          product['product_id'].toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: actionOrange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
          _navItem(Icons.home_rounded, "Home", Colors.white60, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const HomeScreen()),
            );
          }),

          _navItem(
            Icons.storefront_rounded,
            "Shop",
            Colors.white,
            true,
            () {},
          ), 

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddProductScreen()),
              );
              _fetchMyProducts();
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

          _navItem(
            Icons.favorite_outline_rounded,
            "Favorites",
            Colors.white60,
            false,
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const FavoritesScreen()),
              );
            },
          ),

          _navItem(
            Icons.person_outline_rounded,
            "Profile",
            Colors.white60,
            false,
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const ProfileScreen()),
              );
            },
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
