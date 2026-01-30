// ignore_for_file: empty_catches, sized_box_for_whitespace

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'payment_screen.dart';
import 'package:pakcraft/screens/home_screen.dart';
import 'package:pakcraft/screens/favorites_screen.dart';
import 'package:pakcraft/screens/profile_screen.dart';

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
  User? currentUser;

  // Theme Colors
  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);

  bool get isSeller => currentUser?.role == 'seller';

  @override
  void initState() {
    super.initState();
    _loadUserAndCart();
  }

  Future<void> _loadUserAndCart() async {
    User? user = await RemUSer.readUSerInfo();
    setState(() => currentUser = user);
    if (user != null) {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    if (currentUser == null) return;
    try {
      var res = await http.post(
        Uri.parse(API.getCart),
        body: {"user_id": currentUser!.user_id.toString()},
      );

      if (res.statusCode == 200) {
        setState(() {
          cartItems = json.decode(res.body);
          isLoading = false;
        });
        _calculateTotal();
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateQuantity(String cartId, int newQty) async {
    try {
      await http.post(
        Uri.parse(API.updateCart),
        body: {"cart_id": cartId, "quantity": newQty.toString()},
      );
      _fetchCartItems();
    } catch (e) {}
  }

  Future<void> _deleteItem(String cartId) async {
    try {
      await http.post(Uri.parse(API.deleteCart), body: {"cart_id": cartId});
      _fetchCartItems();
    } catch (e) {}
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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        // Seller sees back button, Buyer doesn't
        automaticallyImplyLeading: isSeller,
        leading: isSeller
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: primaryDark),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          "My Cart",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          // Home button only for Buyers (since they have no back button)
          if (!isSeller)
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
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: actionOrange))
                : cartItems.isEmpty
                ? _emptyCart()
                : _cartItemsList(),
          ),
          if (cartItems.isNotEmpty) _checkoutSection(),

          // Show Bottom Nav ONLY for Customers/Buyers
          if (currentUser != null && !isSeller) _buildBottomNav(),
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
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: actionOrange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryDark,
            ),
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
      physics: const BouncingScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) => _cartItem(index),
    );
  }

  Widget _cartItem(int index) {
    var item = cartItems[index];
    int qty = int.parse(item['quantity'].toString());
    String cartId = item['cart_id'].toString();
    String imageUrl =
        "${API.hostConnect}/${item["image_path"].toString().replaceAll('\\', '/')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _deleteItem(cartId),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs. ${item["price"]}",
                  style: TextStyle(
                    fontSize: 16,
                    color: actionOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => qty > 1
                      ? _updateQuantity(cartId, qty - 1)
                      : _deleteItem(cartId),
                  child: Container(
                    width: 30,
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                Text(
                  "$qty",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => _updateQuantity(cartId, qty + 1),
                  child: Container(
                    width: 30,
                    child: const Icon(Icons.add, size: 16),
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
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          _priceRow("Subtotal", "Rs. ${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 10),
          _priceRow("Delivery Charge", "Rs. $deliveryCharge"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _priceRow(
            "Total Amount",
            "Rs. ${total.toStringAsFixed(0)}",
            isTotal: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: actionOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              ),
              child: const Text(
                "Proceed To Checkout",
                style: TextStyle(
                  fontSize: 16,
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
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            color: isTotal ? primaryDark : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isTotal ? actionOrange : primaryDark,
          ),
        ),
      ],
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
            Icons.shopping_bag_outlined,
            "Cart",
            Colors.white,
            true,
            () {},
          ), // ACTIVE
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
