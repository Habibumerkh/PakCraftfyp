import 'dart:ui'; // Required for Glass Effect
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. THEME GRADIENT BACKGROUND
          // Replaces the image to match Login/Signup perfectly
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

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.15),

                // --- GLOWING LOGO ---
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Neon Glow Effect
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7F11).withOpacity(0.6),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage("assets/logo.png"),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5), 
                            width: 2
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- TITLE TEXT ---
                      Text(
                        "PAKCRAFT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.10,
                          fontWeight: FontWeight.w900, // Extra Bold
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 10,
                            )
                          ]
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Discover Art. Buy Local.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // --- BUTTONS ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
                  child: Column(
                    children: [
                      // 1. SIGN UP BUTTON (Solid White - High Visibility)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 25),
                              const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Dark text on white
                                ),
                              ),
                              const Spacer(),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF100D0D), // Dark Circle
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. LOGIN BUTTON (Glassmorphism - Modern Look)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15), // See-through
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 25),
                                  const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text on glass
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2), // Light Circle
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}