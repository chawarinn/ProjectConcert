// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Restaurant/EditPassword.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class OTPRes extends StatefulWidget {
  final String email;
  int expiresAt;
  final int userId;

  OTPRes({
    super.key,
    required this.userId,
    required this.email,
    required this.expiresAt,
  });

  @override
  _OTPResState createState() => _OTPResState();
}

class _OTPResState extends State<OTPRes> {
  bool isLoading = false;
  final TextEditingController _otpController = TextEditingController();

  Future<void> sendOTPAgain() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$API_ENDPOINT/auth/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent again to ${widget.email}")),
        );
        setState(() {
          widget.expiresAt = jsonResponse['expiresAt'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP ไม่ถุ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending OTP: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> confirmOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$API_ENDPOINT/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otp,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPasswordRes(
              userId: widget.userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? "Invalid OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying OTP: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Concert Close Inn',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
      ),
      body:  Padding(
              padding:
                  const EdgeInsets.only(top: 100, right: 16, left: 16),
              child: Column(
                children: [
                  Text(
                    'Enter the password OTP',
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter the OTP sent to your email',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "OTP",
                      filled: true,
                      fillColor: const Color.fromRGBO(217, 217, 217, 1),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton(
                      onPressed: confirmOTP,
                      child: const Text('Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
   
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Didn't receive the OTP? ",
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Send again',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 91, 228),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = sendOTPAgain,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
