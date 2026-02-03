import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakcraft/screens/reset_password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String correctOtp;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.correctOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  void _verify() {
    if (_otpController.text.trim() == widget.correctOtp) {
      Fluttertoast.showToast(msg: "Verified!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Invalid Code. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE0DCD3),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B281D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Security Check",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.security,
                            size: 50,
                            color: Color(0xFFFF7F11),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Verify It's You",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3B281D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "We've sent a 4-digit code to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 35),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 4,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B281D),
                              letterSpacing: 15,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              hintText: "0000",
                              hintStyle: TextStyle(
                                color: Colors.black12,
                                letterSpacing: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7F11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Verify Code",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Code resent!");
                    },
                    child: const Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
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
}
