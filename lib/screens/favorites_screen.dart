// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Real Data Variables
  List _favorites = [];
  bool _isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 1. Load User
  Future<void> _loadData() async {
    currentUser = await RemUSer.readUSerInfo();
    if (currentUser != null) {
      _fetchFavorites();
    }
  }

  // 2. Fetch Favorites from DB
  Future<void> _fetchFavorites() async {
    try {
      var res = await http.post(
        Uri.parse(API.getFavorite),
        body: {"user_id": currentUser!.user_id.toString()},
      );
      if (res.statusCode == 200) {
        setState(() {
          _favorites = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 3. Remove Item (Dismissible Logic)
  Future<void> _removeFromWishlist(String productId) async {
    try {
      await http.post(
        Uri.parse(API.toggleFavorite),
        body: {
          "user_id": currentUser!.user_id.toString(),
          "product_id": productId,
        },
      );
      // We don't fetch again here because Dismissible handles the UI removal visually
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from Favorites")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 4. Add to Cart Logic
  Future<void> _addToCart(String productId) async {
    try {
      var res = await http.post(
        Uri.parse(API.addToCart),
        body: {
          "user_id": currentUser!.user_id.toString(),
          "product_id": productId,
          "quantity": "1",
        },
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to Cart"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6D0C9), // Your Theme Color

      appBar: AppBar(
        backgroundColor: const Color(0xFFD6D0C9),
        elevation: 0,
        title: const Text(
          "Favorites",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8A00)),
            )
          : _favorites.isEmpty
          ? const Center(
              child: Text("No favorites yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final product = _favorites[index];

                // Fix Image URL
                String imageUrl =
                    "${API.hostConnect}/${product['image_path'].toString().replaceAll('\\', '/')}";

                return Dismissible(
                  key: Key(
                    product['product_id'].toString(),
                  ), // Unique Key based on ID
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.redAccent,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    // 1. Remove from UI immediately
                    String pid = product['product_id'].toString();
                    setState(() {
                      _favorites.removeAt(index);
                    });
                    // 2. Remove from Database
                    _removeFromWishlist(pid);
                  },

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        // INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs. ${product['price']}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFE67300),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // ADD TO CART BUTTON
                              GestureDetector(
                                onTap: () {
                                  _addToCart(product['product_id'].toString());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8A00),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Add to Cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
