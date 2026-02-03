import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();

  User? currentUser;
  bool isSeller = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = await RemUSer.readUSerInfo();
    if (user != null) {
      setState(() {
        currentUser = user;
        _nameController.text = user.user_name;
        _phoneController.text = user.user_phone;
        _shopNameController.text = user.shop_name;
        isSeller = user.role == 'seller';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      var res = await http.post(
        Uri.parse(API.updateProfile),
        body: {
          "user_id": currentUser!.user_id.toString(),
          "user_name": _nameController.text,
          "user_phone": _phoneController.text,
          "shop_name": isSeller ? _shopNameController.text : "",
        },
      );

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data['success'] == true) {
          // Update Local User Data
          User updatedUser = User(
            currentUser!.user_id,
            _nameController.text,
            currentUser!.user_email,
            currentUser!.user_password,
            _phoneController.text,
            currentUser!.role,
            isSeller ? _shopNameController.text : "",
            currentUser!.user_image, // Keep existing image
          );

          await RemUSer.saveUSer(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile Updated!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed: ${data['error']}")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    String fullImageUrl = "";
    if (currentUser != null && currentUser!.user_image.isNotEmpty) {
      fullImageUrl =
          "${API.hostConnect}/${currentUser!.user_image.replaceAll('\\', '/')}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0DCD3),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE0DCD3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Color.fromARGB(255, 44, 33, 33),
                          fontSize: 22,
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
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF7F11),
                              width: 3,
                            ),
                            color: const Color(0xFFF5F5F5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: fullImageUrl.isNotEmpty
                                ? Image.network(
                                    fullImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        _buildInput("Full Name", _nameController, Icons.person),
                        const SizedBox(height: 15),
                        _buildInput(
                          "Phone Number",
                          _phoneController,
                          Icons.phone,
                          isNumber: true,
                        ),

                        if (isSeller) ...[
                          const SizedBox(height: 15),
                          _buildInput(
                            "Shop Name",
                            _shopNameController,
                            Icons.store,
                          ),
                        ],

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7F11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(color: Color(0xFF3B281D)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF3B281D)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
