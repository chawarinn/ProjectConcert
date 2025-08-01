import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class EditPasswordLogin extends StatefulWidget {
  final String email;

  EditPasswordLogin({super.key, required this.email});

  @override
  _EditPasswordLoginState createState() => _EditPasswordLoginState();
}

class _EditPasswordLoginState extends State<EditPasswordLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,14}$');

  void _editPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('$API_ENDPOINT/editpasslogin');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'newPassword': _newPasswordController.text.trim(),
        }),
      );

      setState(() {
        _isLoading = false;
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSuccessDialog( 'เปลี่ยนรหัสผ่านสำเร็จ');
      } else {
        _showErrorDialog('ไม่สามารถเปลี่ยนรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Notification'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
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
