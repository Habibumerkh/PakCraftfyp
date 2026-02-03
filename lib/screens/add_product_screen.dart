import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'package:pakcraft/screens/home_screen.dart'; 
import 'package:pakcraft/screens/favorites_screen.dart'; 
import 'package:pakcraft/screens/profile_screen.dart'; 

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Theme Colors
  final Color bgColor = const Color(0xFFE0DCD3);
  final Color primaryDark = const Color(0xFF3B281D);
  final Color actionOrange = const Color(0xFFFF7F11);

  User? currentUser;
  bool get isSeller => currentUser?.role == 'seller';

  String _selectedCategory = "Pottery";
  final List<String> _categories = [
    "Pottery",
    "Jewelry",
    "Textile",
    "Rugs",
    "Woodwork",
    "Accessories",
    "Footwear",
    "Others",
  ];

  File? _imageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    User? user = await RemUSer.readUSerInfo();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _uploadProduct() async {
    if (_imageFile == null ||
        _nameController.text.isEmpty ||
        _priceController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Fill required fields and select image");
      return;
    }
    setState(() => _isLoading = true);

    try {
      User? user = await RemUSer.readUSerInfo();
      if (user == null) return;

      var request = http.MultipartRequest('POST', Uri.parse(API.addProduct));
      request.fields['seller_id'] = user.user_id.toString();
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock_quantity'] = _stockController.text;
      request.fields['category'] = _selectedCategory;
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      var response = await request.send();
      var resString = await response.stream.bytesToString();

      if (response.statusCode == 200 && resString.contains("true")) {
        Fluttertoast.showToast(msg: "Product Uploaded!");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Upload failed: $resString");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _inputField(
    TextEditingController c,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Text(
          "Add Product",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const HomeScreen()),
                  (r) => false,
                );
              },
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _inputField(_nameController, "Product Name"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          _priceController,
                          "Price",
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _inputField(
                          _stockController,
                          "Stock Qty",
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 15),
                  _inputField(_descController, "Description", maxLines: 4),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Upload Product",
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
          _buildBottomNav(),
        ],
      ),
    );
  }


  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, "Home", Colors.white60, false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const HomeScreen()),
            );
          }),

          _navItem(
            Icons.storefront_rounded,
            "Shop",
            Colors.white60,
            false,
            () => Navigator.pushReplacementNamed(context, '/shop'),
          ),

          // ACTIVE BUTTON
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: actionOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: actionOrange.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          _navItem(
            Icons.favorite_outline_rounded,
            "Favorites",
            Colors.white60,
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const FavoritesScreen()),
            ),
          ),

          _navItem(
            Icons.person_outline_rounded,
            "Profile",
            Colors.white60,
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? actionOrange : color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
