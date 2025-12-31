// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartItems = [];
  bool isLoading = true;
  final int deliveryCharge = 200;
  double subtotal = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // 1. Fetch Cart
  Future<void> _fetchCartItems() async {
    User? user = await RemUSer.readUSerInfo();
    if (user == null) return;

    try {
      var res = await http.post(
        Uri.parse(API.getCart),
        body: {"user_id": user.user_id.toString()},
      );

      if (res.statusCode == 200) {
        setState(() {
          cartItems = json.decode(res.body);
          isLoading = false;
        });
        _calculateTotal();
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Update Quantity (NEW FUNCTION)
  Future<void> _updateQuantity(String cartId, int newQty) async {
    try {
      await http.post(
        Uri.parse(API.updateCart),
        body: {"cart_id": cartId, "quantity": newQty.toString()},
      );
      // We update the local UI instantly for speed
      _fetchCartItems();
    } catch (e) {
      print("Error updating: $e");
    }
  }

  // 3. Delete Item
  Future<void> _deleteItem(String cartId) async {
    try {
      await http.post(Uri.parse(API.deleteCart), body: {"cart_id": cartId});
      _fetchCartItems();
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  void _calculateTotal() {
    double sum = 0;
    for (var item in cartItems) {
      double price = double.tryParse(item["price"].toString()) ?? 0;
      int qty = int.tryParse(item["quantity"].toString()) ?? 1;
      sum += price * qty;
    }
    setState(() => subtotal = sum);
  }

  double get total => subtotal + deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd9d4ce),
      appBar: AppBar(
        backgroundColor: const Color(0xffd9d4ce),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                Expanded(
                  child: cartItems.isEmpty ? _emptyCart() : _cartItemsList(),
                ),
                if (cartItems.isNotEmpty) _checkoutSection(),
              ],
            ),
    );
  }

  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xffff8a00),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add some amazing products",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _cartItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: cartItems.length,
      itemBuilder: (context, index) => _cartItem(index),
    );
  }

  Widget _cartItem(int index) {
    var item = cartItems[index];

    // Parse values
    int qty = int.parse(item['quantity'].toString());
    String cartId = item['cart_id'].toString();

    // Construct Image URL
    String imagePath = item["image_path"].toString().replaceAll('\\', '/');
    String imageUrl = "${API.hostConnect}/$imagePath";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _deleteItem(cartId),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs. ${item["price"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // --- QUANTITY CONTROLS (Updated) ---
          Container(
            height: 35,
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: const Color(0xfff5f5f5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // MINUS BUTTON
                GestureDetector(
                  onTap: () {
                    if (qty > 1) {
                      _updateQuantity(cartId, qty - 1);
                    } else {
                      _deleteItem(cartId);
                    }
                  },
                  child: Container(
                    width: 35,
                    alignment: Alignment.center,
                    child: const Icon(Icons.remove, size: 18),
                  ),
                ),

                // QUANTITY TEXT
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "$qty",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // PLUS BUTTON
                GestureDetector(
                  onTap: () {
                    _updateQuantity(cartId, qty + 1);
                  },
                  child: Container(
                    width: 35,
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkoutSection() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _priceRow("Subtotal", "Rs. ${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _priceRow("Delivery", "Rs. $deliveryCharge"),
          const Divider(),
          _priceRow("Total", "Rs. ${total.toStringAsFixed(0)}", isTotal: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffff8a00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              ),
              child: const Text(
                "Proceed To Checkout",
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
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.orange : Colors.black,
          ),
        ),
      ],
    );
  }
}
