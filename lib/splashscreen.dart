// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/home_screen.dart';
import 'package:pakcraft/admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // --- LOGIC TO CHECK IF LOGGED IN ---
  Future<void> _checkLoginStatus() async {
    // 1. Keep the splash visible for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // 2. Check if User Info exists
    User? userInfo = await RemUSer.readUSerInfo();

    if (!mounted) return;

    if (userInfo == null) {
      // Not Logged In -> Go to Welcome Screen
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      // Logged In -> Redirect based on Role
      if (userInfo.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0DCD3), // Beige Theme Background
      body: Stack(
        children: [
          // Optional: Subtle Background Decoration
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF7F11,
                ).withOpacity(0.05), // Faint Orange
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- CENTER CONTENT ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo Container
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 30),

                // 2. App Name
                const Text(
                  "PAKCRAFT",
                  style: TextStyle(
                    color: Color(0xFF3B281D), // Deep Brown
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Intro Text / Slogan
                Text(
                  "Connecting Artisans to the World",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Handcrafted • Authentic • Local",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // 4. Bottom Loading Indicator
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7F11), // Orange Accent
                strokeWidth: 3,
              ),
            ),
          ),

          // 5. Version Number (Optional Polish)
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "v1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
