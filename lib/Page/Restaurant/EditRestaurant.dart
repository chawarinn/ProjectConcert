// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Restaurant/HomeRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/ProfileRestaurant.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/Page/Restaurant/Location.dart';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditRestaurant extends StatefulWidget {
  final int userId;
  final int resID;
  const EditRestaurant({super.key, required this.userId, required this.resID});

  @override
  _EditRestaurantState createState() => _EditRestaurantState();
}

class _EditRestaurantState extends State<EditRestaurant> {
  @override
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _openController = TextEditingController();
  final TextEditingController _closeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  String url = '';
  bool _isFocused = false;
  final FocusNode _FocusNode = FocusNode();
  String? selectedLocation;
  double? selectedLatitude;
  double? selectedLongitude;
  int _currentIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? resData;
  Map<String, dynamic>? originalResData;
  String? _photo;

  @override
  void initState() {
    super.initState();
    fetchResData();

    _FocusNode.addListener(() {
      setState(() {
        _isFocused = _FocusNode.hasFocus;
      });
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });

    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  Future<void> fetchResData() async {
    final url = Uri.parse('$API_ENDPOINT/Res?resID=${widget.resID}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          resData = data;
          originalResData = Map<String, dynamic>.from(data);
          _nameController.text = data['resName'] ?? '';
          _openController.text = data['open'] ?? '';
          _closeController.text = data['close'] ?? '';
          _typeController.text = data['type'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _locationController.text = data['location'] ?? '';
          selectedLatitude = data['lat'];
          selectedLongitude = data['long'];
          selectedLocation = '${data['lat']}, ${data['long']}';
          _photo = data['resPhoto'];
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

  bool _isDataChanged() {
    if (originalResData == null) return true;

    final originalLat = originalResData!['lat']?.toString() ?? '';
    final originalLong = originalResData!['long']?.toString() ?? '';

    return _nameController.text != (originalResData!['resName'] ?? '') ||
        _openController.text != (originalResData!['open'] ?? '') ||
        _closeController.text !=
            (originalResData!['close'] ?? '') ||
        _typeController.text != (originalResData!['type'] ?? '') ||
        _contactController.text != (originalResData!['contact'] ?? '') ||
        _locationController.text != (originalResData!['location'] ?? '') ||
        selectedLatitude?.toString() != originalLat ||
        selectedLongitude?.toString() != originalLong ||
        _image != null;
  }

  void _showEditResultDialog() async {
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
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final nameRegex = RegExp(r'^(?=.*[ก-๙a-zA-Z])[ก-๙a-zA-Z0-9]+( [ก-๙a-zA-Z0-9]+)*$');


 if (_nameController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกชื่อร้าน");
  return;
}

if (_openController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกเวลาเปิดร้าน");
  return;
}

if (_closeController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกเวลาปิดร้าน");
  return;
}

if (_typeController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกประเภทร้านอาหาร");
  return;
}

if (_contactController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกข้อมูลติดต่อ");
  return;
}

if (_locationController.text.isEmpty) {
  _showAlertDialog(context, "กรุณากรอกที่อยู่ร้าน");
  return;
}

if (selectedLatitude == null || selectedLongitude == null) {
  _showAlertDialog(context, "กรุณาเลือกพิกัดร้าน");
  return;
}

if (_image == null) {
  _showAlertDialog(context, "กรุณาเลือกรูปร้านอาหาร");
  return;
}
    bool isValidText(String text) {
      return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
    }

    if (!isValidText(_nameController.text) ||
        !isValidText(_openController.text) ||
        !isValidText(_closeController.text) ||
        !isValidText(_contactController.text) ||
        !isValidText(_typeController.text) ||
        !isValidText(_locationController.text)) {
      _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
      return;
    }
    if (!nameRegex.hasMatch(_nameController.text)) {
      _showAlertDialog(context, "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
      return;
    }
    if (!phoneRegex.hasMatch(_contactController.text)) {
      _showAlertDialog(context, "กรุณาใส่หมายเลขโทรศัพท์ให้ถูกต้อง");
      return;
    }

     try {
    final startTimeParts = _openController.text.split(":");
    final endTimeParts = _closeController.text.split(":");

    final startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(endTimeParts[0]),
      minute: int.parse(endTimeParts[1]),
    );

    bool isStartAfterEnd = startTime.hour > endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute >= endTime.minute);

    if (isStartAfterEnd) {
      _showAlertDialog(context, "เนื่องจากเวลาปิดร้านคือ ${_closeController.text} น. เวลาเปิดร้านและเวลาปิดร้านไม่สอดคล้องกัน ");
      return;
    }
  } catch (e) {
    _showAlertDialog(context, "รูปแบบเวลาไม่ถูกต้อง");
    return;
  }
    final uri = Uri.parse('$API_ENDPOINT/editres');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['resName'] = _nameController.text;
    request.fields['open'] = _openController.text;
    request.fields['close'] = _closeController.text;
    request.fields['type'] = _typeController.text;
    request.fields['contact'] = _contactController.text;
    request.fields['location'] = _locationController.text;
    request.fields['lat'] = selectedLatitude?.toString() ?? '';
    request.fields['long'] = selectedLongitude?.toString() ?? '';
    request.fields['resID'] = widget.resID.toString();

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
      builder: (_) => Center(child: CircularProgressIndicator(color: Colors.black)),
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
            content: Text(data['message'] ?? 'อัปเดตแก้ไขข้อมูลโรงแรมสำเร็จ'),
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
            content: Text('ไม่สามารถอัปเดตร้านอาหารได้'),
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

  @override
  void dispose() {
    _FocusNode.dispose();
    super.dispose();
    _locationController.dispose();
    _addressController.dispose();
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
    } catch (e) {}
  }

  void _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedLatitude = result['latitude'];
        selectedLongitude = result['longitude'];
        selectedLocation = "$selectedLatitude, $selectedLongitude";
        _locationController.text = result['Address'] ?? '';
      });
      log('Selected Location: $selectedLocation');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Edit Restaurant',
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
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No',
                          style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Homerestaurant(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileRestaurant(userId: widget.userId)),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profile',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                      child: Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: _image != null
                                ? FileImage(_image!)
                                : (_photo != null && _photo!.isNotEmpty
                                        ? NetworkImage(_photo!)
                                        : AssetImage('assets/images/album.jpg'))
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(232, 234, 237, 1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Restaurant Name ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextField(
                          controller: _nameController,
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
                            text: 'Food Type ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextField(
                          controller: _typeController,
                          focusNode: _FocusNode,
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
                        if (_isFocused)
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Ex. นานาชาติ, อาหารไทย,...',
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
                            text: 'Contact (Phone Number) ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextField(
                          controller: _contactController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                            text: 'Open ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextFormField(
                          controller: _openController,
                          readOnly: true,
                          onTap: () => _selectTime(context, _openController),
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
                            text: 'Close ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextFormField(
                          controller: _closeController,
                          readOnly: true,
                          onTap: () => _selectTime(context, _closeController),
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
                            text: 'Address ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextField(
                          controller: _locationController,
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
                    child: Row(
                      children: [
                        const Spacer(),
                        if (selectedLocation != null) ...[
                          Text(
                            selectedLocation!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.red),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _selectLocation,
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: _selectLocation,
                            child: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Center(
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () => _showEditResultDialog(),
                          child: Text(
                            "Confirm",
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
