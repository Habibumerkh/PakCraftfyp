import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/screens/otp_verification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var res = await http.post(
        Uri.parse(API.validateEmail),
        body: {"email": email},
      );

      var data = json.decode(res.body);

      if (data['success'] == true) {
        String serverOtp = data['otp'].toString();
        Fluttertoast.showToast(msg: "OTP sent to your email!");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationScreen(email: email, correctOtp: serverOtp),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Email not found");
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
      backgroundColor: const Color(0xFFE0DCD3), // Beige BG
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B281D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Recovery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: size.height * 0.25),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 50,
                            color: Color(0xFFFF7F11),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3B281D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Enter the email address associated with your account. We will send you a code.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 35),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[600],
                              ),
                              hintText: "Enter Email Address",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7F11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Send Code",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF3B281D),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Back to Login",
                          style: TextStyle(
                            color: Color(0xFF3B281D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
