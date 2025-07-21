import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditRoom extends StatefulWidget {
  final int roomID;
  final int userId;
  final int hotelID;
  EditRoom(
      {super.key,
      required this.roomID,
      required this.userId,
      required this.hotelID});

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  final Map<String, double> bedSizeValues = {
    '3.5 ft': 3.5,
    '4 ft': 4.0,
    '5 ft': 5.0,
    '6 ft': 6.0,
  };
  var roomNameCtl = TextEditingController();

  final List<String> nameRoomList = [
    'เตียงเดี่ยว',
    'เตียงคู่',
    'เตียงใหญ่',
    'ห้องสวีท',
    'ห้องแฟมิลี่',
    'เตียงสองชั้น',
  ];
  File? _image;
  bool isLoading = true;
  int roomStatus = 0;
  Map<String, dynamic>? RoomData;
  Map<String, dynamic>? originalRoomData;
  int _currentIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _photo;
  String? selectedSize;
  String url = '';
  @override
  @override
  void initState() {
    super.initState();
    fetchRoomData();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        fetchRoomData();
      });
    });

    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
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
      print(e);
    }
  }

  Future<void> fetchRoomData() async {
    final url = Uri.parse('$API_ENDPOINT/Room?roomID=${widget.roomID}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sizeValue = (data['size'] as num).toDouble();

        final matchedEntry = bedSizeValues.entries.firstWhere(
          (entry) => entry.value == sizeValue,
          orElse: () => MapEntry('', 0),
        );

        setState(() {
          RoomData = data;
          originalRoomData = Map<String, dynamic>.from(data);
          _nameController.text = data['roomName'] ?? '';
          _priceController.text = data['price']?.toString() ?? '';
          selectedSize = matchedEntry.key.isNotEmpty ? matchedEntry.key : null;
          _sizeController.text = selectedSize ?? '';
          _photo = data['photo'];
          roomStatus = data['status'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching room: $e');
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
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
bool _isDataChanged() {
  if (originalRoomData == null) return true;

  String originalSizeKey = bedSizeValues.entries
      .firstWhere(
        (entry) => entry.value == (originalRoomData!['size'] as num).toDouble(),
        orElse: () => MapEntry('', 0.0),
      )
      .key;

  return _nameController.text != (originalRoomData!['roomName'] ?? '') ||
      _priceController.text != (originalRoomData!['price']?.toString() ?? '') ||
      selectedSize != originalSizeKey ||
      roomStatus != (originalRoomData!['status'] ?? 0) ||
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
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _photo == null) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }
    bool isValidText(String text) {
      return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
    }

    if (!isValidText(_nameController.text) ||
        !isValidText(_priceController.text) ||
        !isValidText(_sizeController.text)) {
      _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
      return;
    }

    final uri = Uri.parse('$API_ENDPOINT/editroom');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['roomName'] = _nameController.text;
    request.fields['price'] = _priceController.text;
    request.fields['size'] = _sizeController.text;
    request.fields['roomID'] = widget.roomID.toString();
    request.fields['status'] = roomStatus.toString();

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
      builder: (_) => Center(child: CircularProgressIndicator()),
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
            content: Text('Failed to update profile. (${response.statusCode})'),
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
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.black))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        title: Text(
          'Edit Room',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                    builder: (context) => HomeHotel(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileHotel(userId: widget.userId)),
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
              child: CircularProgressIndicator(),
            )
          :SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: _image != null
                                    ? FileImage(_image!)
                                    : (_photo != null && _photo!.isNotEmpty
                                            ? NetworkImage(_photo!)
                                            : AssetImage(
                                                'assets/images/album.jpg'))
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(232, 234, 237, 1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.black),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Room Name',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 1),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              return nameRoomList.where((String option) {
                                return option.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (String selection) {
                              _nameController.text = selection;
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onFieldSubmitted) {
                              controller.text = _nameController.text;

                              controller.addListener(() {
                                _nameController.text = controller.text;
                              });

                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                onFieldSubmitted: (value) {
                                  onFieldSubmitted();
                                  _nameController.text = value;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(217, 217, 217, 1),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 10, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 1),
                          TextField(
                            controller: _priceController,
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
                      padding:
                          const EdgeInsets.only(top: 5, right: 10, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bed Size',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 1),
                          DropdownButtonFormField<String>(
                            value: bedSizeValues.containsKey(selectedSize)
                                ? selectedSize
                                : null,
                            items: bedSizeValues.keys.map((size) {
                              return DropdownMenuItem(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value!;
                                _sizeController.text = bedSizeValues[selectedSize]!.toString();
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
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("ว่าง"),
                                selected: roomStatus == 0,
                                selectedColor: Colors.green[300],
                                onSelected: (selected) {
                                  setState(() {
                                    roomStatus = 0;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text("เต็ม"),
                                selected: roomStatus == 1,
                                selectedColor: Colors.red[300],
                                onSelected: (selected) {
                                  setState(() {
                                    roomStatus = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Color.fromRGBO(201, 151, 187, 1),
                          ),
                          onPressed: _showEditResultDialog,
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white,fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
