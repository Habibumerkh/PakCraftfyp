// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'home_screen.dart';

class VerificationSuccessScreen extends StatefulWidget {
  final String? email;
  const VerificationSuccessScreen({super.key, this.email});

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFF7F11),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 96, color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Verification Complete",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Redirecting to Home...",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
