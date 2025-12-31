import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/screens/product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    try {
      var res = await http.post(
        Uri.parse(API.getByCategory),
        body: {
          "category": widget.categoryName,
        }, // Sending "Pottery", "Jewelry", etc.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A3D2B), // Dark Brown Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A3D2B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              widget.categoryIcon,
              height: 24,
              width: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              widget.categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No ${widget.categoryName} items found",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index];
                // Fix Image URL
                String imageUrl =
                    "${API.hostConnect}/${product['image_path'].toString().replaceAll('\\', '/')}";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: {
                            'id': product['product_id'],
                            'name': product['name'],
                            'price': product['price'],
                            'image': imageUrl,
                            'description':
                                product['description'] ?? 'No Description',
                            'category': product['category'],
                            'rating': 4.5, // Dummy
                            'reviews': 10,
                            'material': 'Mixed',
                            'seller': 'Handmade Store',
                            'dimensions': 'Standard',
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(
                                color: Colors.grey,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs. ${product['price']}",
                                style: const TextStyle(
                                  color: Color(0xFFFF7F11),
                                  fontWeight: FontWeight.bold,
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
