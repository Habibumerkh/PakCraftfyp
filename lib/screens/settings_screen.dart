// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/login_screen.dart';
import 'package:pakcraft/screens/reset_password.dart';
import 'package:pakcraft/screens/static_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    User? user = await RemUSer.readUSerInfo();
    if (user == null) return;

    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Delete Account?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "This action is permanent. All your data, products, and orders will be removed.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        var res = await http.post(
          Uri.parse(API.deleteUser),
          body: {"user_id": user.user_id.toString()},
        );

        if (res.statusCode == 200) {
          await RemUSer.removeUser();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const LoginScreen()),
            (r) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account Deleted Successfully")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6D0C9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6D0C9),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Security",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _settingsOption(
                    icon: Icons.lock_outline,
                    text: "Change Password",
                    onTap: () async {
                      User? user = await RemUSer.readUSerInfo();
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>
                                ResetPasswordScreen(email: user.user_email),
                          ),
                        );
                      }
                    },
                  ),

                  _settingsOption(
                    icon: Icons.delete_forever_outlined,
                    text: "Delete Account",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- ABOUT SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _settingsOption(
                    icon: Icons.privacy_tip_outlined,
                    text: "Privacy Policy",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  _settingsOption(
                    icon: Icons.info_outline,
                    text: "About PakCraft",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.android, color: Colors.black54, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "PakCraft App v1.0.0",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = const Color(0xFFFF8A00),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
