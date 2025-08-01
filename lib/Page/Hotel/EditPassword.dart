import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'dart:convert';
import 'dart:io';
import 'package:project_concert_closeiin/config/internet_config.dart';

class EditPasswordH extends StatefulWidget {
  final int userId;
  EditPasswordH({super.key, required this.userId});

  @override
  _EditPasswordHState createState() => _EditPasswordHState();
}

class _EditPasswordHState extends State<EditPasswordH> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,14}$');

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _editPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,14}$');

    if (!passwordRegex.hasMatch(newPassword)) {
      _showAlertDialog(
          context, "รหัสผ่านต้องมีความยาว 6-14 ตัว และต้องมีทั้งตัวอักษรและตัวเลข");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessageDialog('รหัสผ่านใหม่กับรหัสยืนยันไม่ตรงกัน');
      return;
    }

    final uri = Uri.parse('$API_ENDPOINT/editpass');

    try {
      // แสดง loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            Center(child: CircularProgressIndicator(color: Colors.black)),
      );

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'newPassword': newPassword,
        }),
      );

      Navigator.pop(context); // ปิด loading dialog

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Notification'),
            content: Text(data['message'] ?? 'เปลี่ยนรหัสผ่านสำเร็จ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileHotel(userId: widget.userId),
                    ),
                  );
                },
                child: Text('OK', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      } else {
        final data = jsonDecode(response.body);
         _showMessageDialog(
            'ไม่สามารถเปลี่ยนรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      Navigator.pop(context);
      _showMessageDialog('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ');
    }
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Notification'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String message,
      {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) onOkPressed();
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildPasswordField({
    String? hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Edit Password',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Password',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'รหัสผ่านต้องมีความยาว 6-14 ตัวและต้องมีทั้งตัวอักษรและตัวเลข',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      hintText: "New Password",
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      toggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกรหัสผ่านใหม่';
                        }
                        if (!passwordRegex.hasMatch(value)) {
                          return 'รหัสผ่านต้องมี 6-14 ตัว และมีทั้งตัวอักษรและตัวเลข';
                        }
                        return null;
                      },
                    ),
                    _buildPasswordField(
                      hintText: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      toggleVisibility: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณายืนยันรหัสผ่าน';
                        }
                        if (value != _newPasswordController.text.trim()) {
                          return 'รหัสผ่านไม่ตรงกัน';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        onPressed: _editPassword,
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
