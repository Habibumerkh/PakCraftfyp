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
    // 1. Keep the splash visible for 3 seconds (UI Experience)
    await Future.delayed(const Duration(seconds: 3));

    // 2. Check if User Info exists in Phone Storage
    User? userInfo = await RemUSer.readUSerInfo();

    if (!mounted) return; // Safety check

    if (userInfo == null) {
      // CASE A: Not Logged In -> Go to Welcome Screen
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      // CASE B: Logged In -> Check Role & Redirect
      if (userInfo.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        // Seller or Customer -> Go to Home
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
      body: Stack(
        children: [
          // 1. THEME GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF100D0D), Color(0xFFFF7F11)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.2, 1.0],
              ),
            ),
          ),

          // 2. CENTER CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- GLOWING LOGO ---
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Neon Glow Effect
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7F11).withOpacity(0.6),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- APP NAME ---
                const Text(
                  "PAKCRAFT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM LOADER
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.5),
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
