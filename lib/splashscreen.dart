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

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    User? userInfo = await RemUSer.readUSerInfo();
    if (!mounted) return;
    if (userInfo == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
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
      backgroundColor: const Color(0xFFE0DCD3),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7F11).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const Text(
                  "PAKCRAFT",
                  style: TextStyle(
                    color: Color(0xFF3B281D),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 10),
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
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7F11),
                strokeWidth: 3,
              ),
            ),
          ),

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
