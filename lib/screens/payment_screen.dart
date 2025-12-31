import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakcraft/api_connection/api_connection.dart';
import 'package:pakcraft/api_connection/model/user.dart';
import 'package:pakcraft/credentials/user_pref/userpref.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "card";
  String? selectedMobileMethod;
  bool isProcessing = false; // Loading state

  // Controllers
  final nameController = TextEditingController();
  final cardController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  // --- PLACE ORDER FUNCTION ---
  Future<void> _processPayment() async {
    // 1. Validation Logic
    if (!_validateFields()) return;

    setState(() => isProcessing = true);

    // 2. Get User Info
    User? user = await RemUSer.readUSerInfo();
    if (user == null) return;

    // 3. Prepare Data
    String paymentMethod = selectedMethod;
    String paymentDetails = "";

    if (selectedMethod == 'card') {
      // Mask the card number for security (e.g., **** 1234)
      String cardNum = cardController.text;
      String last4 = cardNum.length > 4
          ? cardNum.substring(cardNum.length - 4)
          : cardNum;
      paymentDetails = "Card: **** $last4";
    } else if (selectedMethod == 'mobile') {
      paymentMethod = selectedMobileMethod!;
      paymentDetails = "$paymentMethod: ${accountNumberController.text}";
    } else {
      paymentMethod = "COD";
      paymentDetails = "Cash on Delivery";
    }

    String fullAddress = "${addressController.text}, ${cityController.text}";

    // 4. Send to Server
    try {
      var res = await http.post(
        Uri.parse(API.placeOrder),
        body: {
          "user_id": user.user_id.toString(),
          "address": fullAddress,
          "phone": phoneController.text,
          "payment_method": paymentMethod,
          "payment_details": paymentDetails,
        },
      );

      var data = json.decode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        // Success! Go to Success Screen
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) =>
              false, // Remove back stack so they can't go back to payment
        );
      } else {
        _showError("Failed: ${data['message'] ?? data['error']}");
      }
    } catch (e) {
      _showError("Connection Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  bool _validateFields() {
    if (fullNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showError("Please fill all delivery details");
      return false;
    }
    if (selectedMethod == 'card' && cardController.text.isEmpty) {
      _showError("Enter card details");
      return false;
    }
    if (selectedMethod == 'mobile' &&
        (selectedMobileMethod == null ||
            accountNumberController.text.isEmpty)) {
      _showError("Enter wallet details");
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd9d4ce),
      appBar: AppBar(
        backgroundColor: const Color(0xffd9d4ce),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _paymentOption(
              method: "card",
              label: "Credit / Debit Card",
              icon: Icons.credit_card,
            ),
            _paymentOption(
              method: "cod",
              label: "Cash on Delivery",
              icon: Icons.money,
            ),
            _paymentOption(
              method: "mobile",
              label: "Mobile Wallet",
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 20),

            if (selectedMethod == "mobile") _buildMobilePaymentOptions(),
            if (selectedMethod == "card") _buildCardDetails(),
            if (selectedMethod == "mobile" && selectedMobileMethod != null)
              _buildMobileAccountDetails(),

            _buildDeliveryDetails(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff8a00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isProcessing ? null : _processPayment,
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep your existing Widget helpers: _paymentOption, _buildCardDetails, etc. exactly as they were in your code)
  // I am re-pasting them here for completeness so you can copy-paste the whole file easily.

  Widget _paymentOption({
    required String method,
    required String label,
    required IconData icon,
  }) {
    bool isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          if (method != "mobile") selectedMobileMethod = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xffff8a00) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xffff8a00), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xffff8a00) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaymentOptions() {
    return Row(
      children: [
        Expanded(
          child: _mobileWalletOption(
            label: "EasyPaisa",
            isSelected: selectedMobileMethod == "easypaisa",
            onTap: () => setState(() => selectedMobileMethod = "easypaisa"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _mobileWalletOption(
            label: "JazzCash",
            isSelected: selectedMobileMethod == "jazzcash",
            onTap: () => setState(() => selectedMobileMethod = "jazzcash"),
          ),
        ),
      ],
    );
  }

  Widget _mobileWalletOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xffff8a00) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xffff8a00) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetails() {
    return Column(
      children: [
        _textField("Cardholder Name", nameController),
        _textField(
          "Card Number",
          cardController,
          keyboard: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(child: _textField("Expiry", expiryController)),
            const SizedBox(width: 10),
            Expanded(
              child: _textField(
                "CVV",
                cvvController,
                keyboard: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileAccountDetails() {
    return Column(
      children: [
        _textField("Account Holder Name", accountNameController),
        _textField(
          "${selectedMobileMethod == "easypaisa" ? "EasyPaisa" : "JazzCash"} Number",
          accountNumberController,
          keyboard: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Delivery Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _textField("Full Name", fullNameController),
        _textField(
          "Phone Number",
          phoneController,
          keyboard: TextInputType.phone,
        ),
        _textField("Complete Address", addressController),
        _textField("City", cityController),
      ],
    );
  }

  Widget _textField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
