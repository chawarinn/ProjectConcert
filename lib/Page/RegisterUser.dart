import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class RegisterPageUser extends StatefulWidget {
  const RegisterPageUser({super.key});

  @override
  State<RegisterPageUser> createState() => _RegisterPageUserState();
}

class _RegisterPageUserState extends State<RegisterPageUser> {
  var fullnameCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var emailCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  var confirmpassCtl = TextEditingController();
  final FocusNode _confirmFocusNode = FocusNode();
  bool _isConfirmFocused = false;
  String? selectedGender;
  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to say'];
  File? _image;
  String url = '';
  String? selectedUserType;
  final List<String> userTypes = ['User', 'Hotel', 'Restaurant', 'Organizer'];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
     _confirmFocusNode.addListener(() {
      setState(() {
        _isConfirmFocused = _confirmFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    passwordCtl.dispose();
    confirmpassCtl.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showAlertDialog(context, "Image selection failed: $e");
    }
  }

  Future<void> _registerUser(BuildContext context) async {
    final nameRegex = RegExp(r'^(?=.*[a-zA-Zก-๙])[a-zA-Zก-๙0-9]{2,}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,14}$');
    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (fullnameCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        emailCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmpassCtl.text.isEmpty ||
        selectedUserType == null ||
        selectedUserType!.isEmpty ||
        selectedGender == null ||
        selectedGender!.isEmpty) {
      _showAlertDialog(context, "กรุณากรอกข้อมูลให้ครบ");
      return;
    }
    if (fullnameCtl.text.contains(' ') ||
        fullnameCtl.text.trim() != fullnameCtl.text ||
        phoneCtl.text.contains(' ') ||
        phoneCtl.text.trim() != phoneCtl.text ||
        emailCtl.text.contains(' ') ||
        emailCtl.text.trim() != emailCtl.text ||
        passwordCtl.text.contains(' ') ||
        passwordCtl.text.trim() != passwordCtl.text ||
        confirmpassCtl.text.contains(' ') ||
        confirmpassCtl.text.trim() != confirmpassCtl.text) {
      _showAlertDialog(context, "ห้ามเว้นวรรค");
      return;
    }
if (!nameRegex.hasMatch(fullnameCtl.text)) {
  _showAlertDialog(context,
    "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
  return;
}

    if (!phoneRegex.hasMatch(phoneCtl.text)) {
      _showAlertDialog(context,
          "กรุณาใส่หมายเลขโทรศัพท์ให้ถูกต้อง");
      return;
    }

    if (!emailRegex.hasMatch(emailCtl.text)) {
      _showAlertDialog(context, "รูปแบบอีเมลไม่ถูกต้อง");
      return;
    }
    if (!passwordRegex.hasMatch(passwordCtl.text)) {
      _showAlertDialog(context,
          "รหัสผ่านต้องมีความยาว 6-14 ตัว และต้องมีทั้งตัวอักษรและตัวเลข");
      return;
    }

    if (passwordCtl.text != confirmpassCtl.text) {
      _showAlertDialog(context, "รหัสผ่านไม่ตรงกัน");
      return;
    }

    if (_image == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูปโปรไฟล์");
      return;
    }

    try {
      showLoadingDialog(); 
      var uri = Uri.parse("$API_ENDPOINT/registerU");
      var request = http.MultipartRequest('POST', uri);

      var imageStream = http.ByteStream(_image!.openRead());
      var imageLength = await _image!.length();

      var multipartFile = http.MultipartFile(
        'file',
        imageStream,
        imageLength,
        filename: path.basename(_image!.path),
      );

      request.files.add(multipartFile);
      request.fields['name'] = fullnameCtl.text;
      request.fields['gender'] = selectedGender ?? '';
      request.fields['phone'] = phoneCtl.text;
      request.fields['email'] = emailCtl.text;
      request.fields['password'] = passwordCtl.text;
      request.fields['confirmPassword'] = confirmpassCtl.text;
      request.fields['userType'] = selectedUserType ?? '';

      var response = await request.send();

       hideLoadingDialog();

      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        log(data);

        _showAlertDialog(context, "สมัครสมาชิกสำเร็จ", onOkPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
      } else {
        var errorData = await response.stream.bytesToString();
        log(errorData);
        _showAlertDialog(
            context, "ไม่สามารถสมัครสมาชิกได้ เบอร์โทรหรืออีเมลนี้ถูกใช้ไปแล้ว");
      }
    } catch (e) {
      hideLoadingDialog();
      _showAlertDialog(context, "Error during registration: $e");
    }
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
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
  void showLoadingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(color: Colors.black),
    ),
  );
}

void hideLoadingDialog() {
  Navigator.of(context, rootNavigator: true).pop();
}


  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Concert Close Inn",
                style: TextStyle(fontSize: 35),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/images/Profile.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromRGBO(232, 234, 237, 1),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Name ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: fullnameCtl,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Gender ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: genderOptions.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: const Color.fromRGBO(217, 217, 217, 1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Phone ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: phoneCtl,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Email ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: emailCtl,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Password ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: passwordCtl,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
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
                  const SizedBox(height: 5),
          if (_isPasswordFocused)
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'รหัสผ่านต้องมีความยาว 6-14 ตัวและต้องมีทั้งตัวอักษรและตัวเลข',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Confirm Password ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: confirmpassCtl,
                    focusNode: _confirmFocusNode,
                    obscureText: true,
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
                  const SizedBox(height: 5),
              if (_isConfirmFocused)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                'รหัสผ่านต้องมีความยาว 6-14 ตัวและต้องมีทั้งตัวอักษรและตัวเลข',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
                ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'User type ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedUserType,
                    items: userTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                      });
                    },
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: const Color.fromRGBO(
                        217, 217, 217, 1), // พื้นหลังเมนู dropdown
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 190, 150, 198),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => _registerUser(context),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
