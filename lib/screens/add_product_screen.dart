// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _imageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;

  // 1. Pick Image Function
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 2. Upload Function
  Future<void> _uploadProduct() async {
    if (_imageFile == null) {
      Fluttertoast.showToast(msg: "Please pick an image");
      return;
    }
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Fill required fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get Current User ID
      User? user = await RemUSer.readUSerInfo();
      if (user == null) return;

      var request = http.MultipartRequest('POST', Uri.parse(API.addProduct));
      
      // Add Text Fields
      request.fields['seller_id'] = user.user_id.toString();
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock_quantity'] = _stockController.text;
      request.fields['category'] = _categoryController.text;

      // Add Image File
      var pic = await http.MultipartFile.fromPath('image', _imageFile!.path);
      request.files.add(pic);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if(responseString.contains("true")) {
           Fluttertoast.showToast(msg: "Product Uploaded Successfully!");
           Navigator.pop(context); // Close screen
        } else {
           Fluttertoast.showToast(msg: "Failed: $responseString");
        }
      } else {
        Fluttertoast.showToast(msg: "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add New Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF100D0D), Color(0xFFFF7F11)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.1, 0.9],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- IMAGE PICKER ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        image: _imageFile != null 
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _imageFile == null 
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white, size: 50),
                              SizedBox(height: 10),
                              Text("Tap to upload Image", style: TextStyle(color: Colors.white70)),
                            ],
                          )
                        : null,
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // --- INPUT FIELDS ---
                  _glassTextField(_nameController, "Product Name", Icons.shopping_bag),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _glassTextField(_priceController, "Price (Rs)", Icons.attach_money, isNumber: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _glassTextField(_stockController, "Stock Qty", Icons.inventory, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _glassTextField(_categoryController, "Category (e.g. Art, Pottery)", Icons.category),
                  const SizedBox(height: 15),
                  _glassTextField(_descController, "Description", Icons.description, maxLines: 3),

                  const SizedBox(height: 30),

                  // --- UPLOAD BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Upload Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}