// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Member/OTP.dart';
import 'dart:io';
import 'package:project_concert_closeiin/config/internet_config.dart';

class SendOTP extends StatefulWidget {
  int userId;
  SendOTP({super.key, required this.userId});

  @override
  _SendOTPState createState() => _SendOTPState();
}

class _SendOTPState extends State<SendOTP> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator(color: Colors.black)),
        );
      },
    );
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('$API_ENDPOINT/user?userID=${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          _emailController.text = data['email'] ?? '';
          isLoading = false;
        });
    } else {
        setState(() {
          isLoading = false;
        });
       showErrorDialog("ไม่พบอีเมลนี้ในระบบ");
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง");
    }
  }

    void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notification"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, right: 16, left: 16),
                child: Column(
                  children: [
                    Text(
                      'Forgot your password?',
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please enter your E-mail and we will send your password to your E-mail to reset your password',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
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
                        onPressed: () async {
                          final email = _emailController.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("กรุณากรอกอีเมลให้ถูกต้อง")),
                            );
                            return;
                          }

                          final url =
                              Uri.parse('$API_ENDPOINT/auth/send-otp');

                          showLoadingDialog(); // show loading

                          try {
                            final response = await http.post(
                              url,
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({'email': email}),
                            );

                            Navigator.pop(context); // close loading

                            final result = jsonDecode(response.body);

                            if (response.statusCode == 200 &&
                                result['success']) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OTP(
                                    userId: widget.userId,
                                    email: email,
                                    expiresAt: result['expiresAt'],
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Notification"),
                                  content: Text("อีเมลไม่ถูกต้อง"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: Text("OK",
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.pop(context); // close loading

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Error"),
                                content: Text(
                                    "กรุณากรอกอีเมลให้ถูกต้อง"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text('Send OTP',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
