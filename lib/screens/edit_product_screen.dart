// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/api_connection/api_connection.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
 
  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  
  late String _selectedCategory;
  final List<String> _categories = [
    "Pottery",
    "Jewelry",
    "Textile",
    "Rugs",
    "Woodwork",
    "Accessories",
    "Footwear",
    "Others",
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.product['name'];
    _descController.text = widget.product['description'];
    _priceController.text = widget.product['price'].toString();
    _stockController.text = widget.product['stock_quantity'].toString();

    String dbCategory = widget.product['category'] ?? "Pottery";
    if (_categories.contains(dbCategory)) {
      _selectedCategory = dbCategory;
    } else {
      _selectedCategory = _categories[0];
    }
  }

  Future<void> _updateProduct() async {
    setState(() => _isLoading = true);

    try {
      var res = await http.post(
        Uri.parse(API.editProduct),
        body: {
          "product_id": widget.product['product_id'].toString(),
          "name": _nameController.text,
          "description": _descController.text,
          "price": _priceController.text,
          "stock_quantity": _stockController.text,
          "category": _selectedCategory,
        },
      );

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data['success'] == true) {
          Fluttertoast.showToast(msg: "Product Updated Successfully!");
          Navigator.pop(context, true);
        } else {
          Fluttertoast.showToast(msg: "Failed: ${data['error']}");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,

        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Product",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
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
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () =>
                  Navigator.pop(context), // Takes them back to Shop
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildInputField(
              _nameController,
              "Product Name",
              Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    _priceController,
                    "Price",
                    Icons.payments_outlined,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    _stockController,
                    "Stock",
                    Icons.inventory_2_outlined,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            _buildDropdownField(),
            const SizedBox(height: 15),

            _buildInputField(
              _descController,
              "Description",
              Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionOrange,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon, color: primaryDark),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category_outlined, color: primaryDark),
          border: InputBorder.none,
          labelText: "Category",
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        items: _categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedCategory = newValue!;
          });
        },
      ),
    );
  }
}
