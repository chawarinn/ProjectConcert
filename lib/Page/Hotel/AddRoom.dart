import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddRoom extends StatefulWidget {
  final int hotelID;
  AddRoom({super.key, required this.hotelID});

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  var priceCtl = TextEditingController();
  var sizeCtl = TextEditingController();
  File? _image;
  String roomName = 'เตียงเดี่ยว';

  var price2Ctl = TextEditingController();
  var size2Ctl = TextEditingController();
  File? _image2;
  String roomName2 = 'เตียงคู่';

  bool isSaved = false;
    bool isSaved2 = false;

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
      print(e);
    }
  }
    Future<void> _pickImage2() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image2 = File(pickedFile.path);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addRoom() async {
    if (priceCtl.text.isEmpty || sizeCtl.text.isEmpty) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }

    if (_image == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูป");
      return;
    }

    var uri = Uri.parse("$API_ENDPOINT/addroom");
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
    request.fields['roomName'] = roomName;
    request.fields['hotelID'] = widget.hotelID.toString();
    request.fields['price'] = priceCtl.text;
    request.fields['size'] = sizeCtl.text;
    request.fields['status'] = '0'; // Example status

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        // Room added successfully
        _showAlertDialog(context, "เพิ่มห้องสำเร็จ");
      } else {
        _showAlertDialog(context, "เกิดข้อผิดพลาดในการเพิ่มห้อง");
      }
    } catch (e) {
      print(e);
      _showAlertDialog(context, "เกิดข้อผิดพลาดในการเพิ่มห้อง");
    }
  }

   Future<void> addRoom2() async {
    if (price2Ctl.text.isEmpty || size2Ctl.text.isEmpty) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }

    if (_image2 == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูป");
      return;
    }

    var uri = Uri.parse("$API_ENDPOINT/addroom");
    var request = http.MultipartRequest('POST', uri);

    var imageStream = http.ByteStream(_image2!.openRead());
    var imageLength = await _image2!.length();
    var multipartFile = http.MultipartFile(
      'file',
      imageStream,
      imageLength,
      filename: path.basename(_image2!.path),
    );

    request.files.add(multipartFile);
    request.fields['roomName'] = roomName2;
    request.fields['hotelID'] = widget.hotelID.toString();
    request.fields['price'] = price2Ctl.text;
    request.fields['size'] = size2Ctl.text;
    request.fields['status'] = '0'; // Example status

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        // Room added successfully
        _showAlertDialog(context, "เพิ่มห้องสำเร็จ");
      } else {
        _showAlertDialog(context, "เกิดข้อผิดพลาดในการเพิ่มห้อง");
      }
    } catch (e) {
      print(e);
      _showAlertDialog(context, "เกิดข้อผิดพลาดในการเพิ่มห้อง");
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
                 setState(() {
          isSaved = true; // เปลี่ยนสถานะเป็นบันทึกแล้ว
          isSaved2 = true;
        });
              },
              child: const Text("OK"),
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
        title: Text(
          'Add Room',
           style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
                      child: const Text('No',style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 200,
                width: 400,
                child: Container(
                  color: Color.fromRGBO(200, 200, 200, 0.2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              roomName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 5),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: _image != null
                                          ? FileImage(_image!)
                                          : const AssetImage(
                                                  'assets/images/Profile.png')
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                 isSaved
                                ? Container() // ซ่อนปุ่ม Save เมื่อบันทึกเสร็จ
                                :Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(232, 234, 237, 1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.black),
                                      onPressed: _pickImage,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                TextField(
                                  controller: priceCtl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Size',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                TextField(
                                  controller: sizeCtl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child:  isSaved
                                ? Container() // ซ่อนปุ่ม Save เมื่อบันทึกเสร็จ
                                :SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 190, 150, 198),
                                ),
                                onPressed: addRoom,
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 200,
                width: 400,
                child: Container(
                  color: Color.fromRGBO(200, 200, 200, 0.2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              roomName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 5),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: _image2 != null
                                          ? FileImage(_image2!)
                                          : const AssetImage(
                                                  'assets/images/Profile.png')
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                 isSaved2
                                ? Container() // ซ่อนปุ่ม Save เมื่อบันทึกเสร็จ
                                :Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(232, 234, 237, 1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.black),
                                      onPressed: _pickImage2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                TextField(
                                  controller: price2Ctl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Size',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                TextField(
                                  controller: size2Ctl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child:  isSaved2
                                ? Container() // ซ่อนปุ่ม Save เมื่อบันทึกเสร็จ
                                :SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 190, 150, 198),
                                ),
                                onPressed: addRoom2,
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
