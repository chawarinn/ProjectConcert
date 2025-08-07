import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/Page/Member/SendOTP.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class EditProfileMember extends StatefulWidget {
  final int userId;
  EditProfileMember({super.key, required this.userId});

  @override
  _EditProfileMemberState createState() => _EditProfileMemberState();
}

class _EditProfileMemberState extends State<EditProfileMember> {
  File? _image;
  int _currentIndex = 3;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? originalUserData;
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to say'];
  String? _photo;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('$API_ENDPOINT/user?userID=${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          originalUserData = Map<String, dynamic>.from(data);
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';

          final genderFromDb = (data['gender'] ?? '').toString().toLowerCase();
          switch (genderFromDb) {
            case 'male':
              _selectedGender = 'Male';
              break;
            case 'female':
              _selectedGender = 'Female';
              break;
            case 'prefer not to say':
              _selectedGender = 'Prefer not to say';
              break;
            default:
              _selectedGender = null;
          }
          _photo = data['photo'];

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching user: $e');
    }
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
      // handle error if needed
    }
  }

  bool _isDataChanged() {
    if (originalUserData == null) return true;
    return _nameController.text != (originalUserData!['name'] ?? '') ||
        _phoneController.text != (originalUserData!['phone'] ?? '') ||
        _emailController.text != (originalUserData!['email'] ?? '') ||
        _selectedGender != (originalUserData!['gender'] ?? '') ||
        _image != null;
  }

  String formatGender(String input) {
    return input
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _showEditResultDialog() async {
    final nameRegex = RegExp(r'^(?=.*[a-zA-Zก-๙])[a-zA-Zก-๙0-9]{2,}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^0[0-9]{9}$');

    if (!_isDataChanged()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Notification'),
          content: Text('กรุณาอัปเดตข้อมูลก่อนกดยืนยัน'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.black))),
          ],
        ),
      );
      return;
    }

    if (!nameRegex.hasMatch(_nameController.text)) {
      _showAlertDialog(context, "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
      return;
    }

    if (!phoneRegex.hasMatch(_phoneController.text)) {
      _showAlertDialog(context, "กรุณาใส่หมายเลขโทรศัพท์ให้ถูกต้อง");
      return;
    }

    if (!emailRegex.hasMatch(_emailController.text)) {
      _showAlertDialog(context, "รูปแบบอีเมลไม่ถูกต้อง");
      return;
    }

    // เช็คฟิลด์บังคับ
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedGender == null) {
      _showAlertDialog(context, "กรุณากรอกข้อมูลให้ครบ");
      return;
    }
    final uri = Uri.parse('$API_ENDPOINT/editprofile');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['name'] = _nameController.text;
    request.fields['gender'] = _selectedGender!;

    request.fields['phone'] = _phoneController.text;
    request.fields['email'] = _emailController.text;
    request.fields['userId'] = widget.userId.toString();

    if (_image != null) {
      final fileStream = http.ByteStream(_image!.openRead());
      final length = await _image!.length();

      request.files.add(http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: _image!.path.split('/').last,
      ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context); // ปิด loading

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Notification'),
            content: Text('อัปเดตแก้ไขข้อมูลส่วนตัวสำเร็จ'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: Text('OK', style: TextStyle(color: Colors.black))),
            ],
          ),
        );
     } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Notification'),
            content: Text('ไม่สามารถอัปเดตโปรไฟล์ได้'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK', style: TextStyle(color: Colors.black))),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading
      showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Notification'), // = การแจ้งเตือน
      content: Text('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ'), // = อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: TextStyle(color: Colors.black)), // = ตกลง
        ),
      ],
    );
  },
);
    }
  }

  void _EditPassword() async {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,14}$');

    if (!passwordRegex.hasMatch(_newPasswordController.text)) {
      _showAlertDialog(context,
          "รหัสผ่านต้องมีความยาว 6-14 ตัว และต้องมีทั้งตัวอักษรและตัวเลข");
      return;
    }
    final currentPassword = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessageDialog('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessageDialog('รหัสผ่านใหม่กับรหัสยืนยันไม่ตรงกัน');
      return;
    }

    final uri = Uri.parse('$API_ENDPOINT/editpassword');

    try {
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
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _passwordController.clear();
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
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: Text('OK', style: TextStyle(color: Colors.black))),
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
            onPressed: () {
              Navigator.pop(context, true);
            },
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

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 18, color: Colors.black)),
              if (isRequired) Text('*', style: TextStyle(color: Colors.red)),
            ],
          ),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: toggleObscure,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 18, color: Colors.black)),
              if (isRequired) Text('*', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ))
                .toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onChanged,
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        automaticallyImplyLeading: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('คุณต้องการที่จะออกจากระบบหรือไม่?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                                final box = GetStorage();
                        box.erase();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : (_photo != null && _photo!.isNotEmpty
                                      ? NetworkImage(_photo!)
                                      : AssetImage('assets/images/Profile.png'))
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                const Color.fromRGBO(232, 234, 237, 1),
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.black),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTextField(
                      label: 'Name',
                      hintText: '',
                      controller: _nameController,
                      isRequired: true),
                  _buildDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    items: genderOptions,
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  _buildTextField(
                      label: 'Phone',
                      hintText: '',
                      controller: _phoneController,
                      isRequired: true),
                  _buildTextField(
                      label: 'E-mail',
                      hintText: '',
                      controller: _emailController,
                      isRequired: true),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _showEditResultDialog,
                    child: Text('Confirm',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Edit Password',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'รหัสผ่านต้องมีความยาว 6-14 ตัวและต้องมีทั้งตัวอักษรและตัวเลข**',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                  _buildTextField(
                      label: 'Password',
                      hintText: '',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      toggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      isPassword: true,
                      isRequired: true),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SendOTP(userId: widget.userId)),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 0, 91, 228),
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  const Color.fromARGB(255, 0, 91, 228),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTextField(
                    label: 'New Password',
                    hintText: '',
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    toggleObscure: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    isPassword: true,
                    isRequired: true,
                  ),
                  _buildTextField(
                    label: 'Confirm Password',
                    hintText: '',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    toggleObscure: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    isPassword: true,
                    isRequired: true,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _EditPassword,
                    child: Text('Confirm',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
  final box = GetStorage();
  switch (index) {
    case 0:
      await box.write('lastVisitedPage', 'home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homemember(userId: widget.userId)),
      );
      break;
    case 1:
      await box.write('lastVisitedPage', 'artist');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArtistPage(userId: widget.userId)),
      );
      break;
    case 2:
      await box.write('lastVisitedPage', 'notification');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotificationPage(userId: widget.userId)),
      );
      break;
    case 3:
      await box.write('lastVisitedPage', 'profile');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileMember(userId: widget.userId)),
      );
      break;
  }
},

        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
