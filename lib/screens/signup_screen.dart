// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'customer';

  Future<void> _apiSignup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(API.signup),
            body: {
              "user_name": _nameController.text.trim(),
              "user_email": _emailController.text.trim(),
              "user_password": _passwordController.text.trim(),
              "user_phone": _phoneController.text.trim(),
              "role": _selectedRole,
              "shop_name": _selectedRole == 'seller'
                  ? _shopNameController.text.trim()
                  : '',
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Fluttertoast.showToast(msg: "Registration successful!");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Registration failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE0DCD3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: size.height * 0.30,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B281D),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),

                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/logo.png'),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Join PakCraft",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B281D),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Register to start your journey",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Inputs
                    _buildInput(
                      controller: _nameController,
                      hint: "Full Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    _buildInput(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    _buildInput(
                      controller: _phoneController,
                      hint: "Phone Number",
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Register as:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B281D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _roleCard(
                            "Buyer",
                            Icons.shopping_bag_outlined,
                            'customer',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _roleCard(
                            "Seller",
                            Icons.store_outlined,
                            'seller',
                          ),
                        ),
                      ],
                    ),

                    if (_selectedRole == 'seller') ...[
                      const SizedBox(height: 15),
                      _buildInput(
                        controller: _shopNameController,
                        hint: "Shop Name",
                        icon: Icons.store,
                      ),
                    ],

                    const SizedBox(height: 15),
                    _buildInput(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVis: _isPasswordVisible,
                      toggle: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInput(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isVis: _isConfirmPasswordVisible,
                      toggle: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _apiSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B281D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SIGN UP",
                                style: TextStyle(
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
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Color(0xFF3B281D)),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Color(0xFFFF7F11),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVis = false,
    VoidCallback? toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVis,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF3B281D)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVis ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggle,
                )
              : null,
        ),
      ),
    );
  }

  Widget _roleCard(String title, IconData icon, String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B281D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B281D).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF3B281D),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
