import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:developer';
import 'dart:convert';  
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetRegisResponse.dart';

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
  var confirmpassCtl = TextEditingController();
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
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      // _showAlertDialog(context, "Image selection failed: $e");
    }
  }

   Future<void> _registerUser(BuildContext context) async {
  if (fullnameCtl.text.isEmpty ||
      phoneCtl.text.isEmpty ||
      emailCtl.text.isEmpty ||
      passwordCtl.text.isEmpty ||
      confirmpassCtl.text.isEmpty ||
      selectedUserType == null || selectedUserType!.isEmpty) {
    _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
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
    request.fields['phone'] = phoneCtl.text;
    request.fields['email'] = emailCtl.text;
    request.fields['password'] = passwordCtl.text;
    request.fields['confirmPassword'] = confirmpassCtl.text;
    request.fields['userType'] = selectedUserType ?? '';

    var response = await request.send();

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
      _showAlertDialog(context, "ไม่สามารถสมัครสมาชิกได้ เบอร์นี้ถูกใช้ไปแล้ว");
    }
  } catch (e) {
    _showAlertDialog(context, "Error during registration: $e");
  }
}


  void _showAlertDialog(BuildContext context, String message, {VoidCallback? onOkPressed}) {
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
 Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
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
        backgroundColor: const Color.fromARGB(255, 190, 150, 198),
        title: const Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                        : const AssetImage('assets/images/Profile.png') as ImageProvider,
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
                  Text(
                    'Name',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: fullnameCtl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
                  const Text(
                    'Phone',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: phoneCtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
                  const Text(
                    'E-mail',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: emailCtl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
                  const Text(
                    'Password',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: passwordCtl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
                  const Text(
                    'Confirm Password',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: confirmpassCtl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
                  const Text(
                    'User type',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedUserType,
                    items: userTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUserType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
               padding:  EdgeInsets.fromLTRB(20, 40, 20, 30),
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
                    child:  Text(
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
