// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isAdding = false;
  bool isFavorite = false;

  Future<void> _addToCart() async {
    setState(() => isAdding = true);

    User? user = await RemUSer.readUSerInfo();
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please Login First")));
      setState(() => isAdding = false);
      return;
    }

    var productId = widget.product['id'] ?? widget.product['product_id'];

    try {
      var res = await http.post(
        Uri.parse(API.addToCart),
        body: {
          "user_id": user.user_id.toString(),
          "product_id": productId.toString(),
          "quantity": quantity.toString(),
        },
      );

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Added to Cart!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed: ${data['error']}")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isAdding = false);
    }
  }

  void _toggleFavorite() async {
    User? user = await RemUSer.readUSerInfo();
    if (user == null) return;

    setState(() => isFavorite = !isFavorite);

    var productId = widget.product['id'] ?? widget.product['product_id'];
    try {
      await http.post(
        Uri.parse(API.toggleFavorite),
        body: {
          "user_id": user.user_id.toString(),
          "product_id": productId.toString(),
        },
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.product['name'] ?? "Unknown";
    String price = widget.product['price'].toString();
    String description =
        widget.product['description'] ?? "No description available.";
    String category = widget.product['category'] ?? "General";

    String sellerName = widget.product['shop_name'] ?? "Unknown Shop";

    String imagePath = widget.product['image'] != null
        ? widget.product['image'].toString().replaceAll('\\', '/')
        : widget.product['image_path'].toString().replaceAll('\\', '/');

    if (!imagePath.startsWith('http') && !imagePath.startsWith('assets')) {
      imagePath = "${API.hostConnect}/$imagePath";
    }

    bool isNetworkImage = imagePath.startsWith('http');

    String rating = "4.5";
    String reviews = "12";
    String material = "Mixed Material";
    String dimensions = "Standard";

    return Scaffold(
      backgroundColor: const Color(0xFFE0DCD3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                    ),
                    const Text(
                      "Product Detail",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: isNetworkImage
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              color: Colors.white,
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              color: Colors.white,
                              child: const Icon(Icons.image, size: 50),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B281D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rs. $price",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFFF7F11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE67300),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " ($reviews reviews)",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Product Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _detailRow("Material", material),
                      _detailRow("Seller", sellerName),
                      _detailRow("Dimensions", dimensions),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add, color: Color(0xFFFF7F11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isAdding ? null : _addToCart,
                        child: isAdding
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Add To Cart",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const CartScreen()),
                        ),
                        child: const Text(
                          "View Cart",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
