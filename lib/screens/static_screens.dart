import 'package:flutter/material.dart';
import 'package:pakcraft/screens/home_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPolicyCard(
              "Data Collection",
              "We collect minimal personal information (Name, Email, Phone) required to process your orders. All data is stored securely in our local database.",
            ),
            _buildPolicyCard(
              "Data Usage",
              "Your data is used solely for the purpose of connecting you with sellers and fulfilling handicraft orders. We do not share your data with third parties.",
            ),
            _buildPolicyCard(
              "Security",
              "We implement standard security measures including password encryption and secure API communication to ensure your data remains protected.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "About PakCraft",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF3B281D),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with premium styling
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "PakCraft",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primaryDark,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                "Handcrafted Excellence • v1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "PakCraft is a dedicated platform designed to empower local Pakistani artisans by connecting them directly with buyers. We aim to digitize the handicraft industry and preserve our cultural heritage.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: primaryDark.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                "© 2026 PakCraft Inc.",
                style: TextStyle(
                  fontSize: 12,
                  color: primaryDark.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
