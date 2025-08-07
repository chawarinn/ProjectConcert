// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'dart:io';

class AddRoomShare extends StatefulWidget {
  final int userId;
  const AddRoomShare({super.key, required this.userId});

  @override
  State<AddRoomShare> createState() => _AddRoomShareState();
}

class _AddRoomShareState extends State<AddRoomShare> {
  final eventCtl = TextEditingController();
  final hotelCtl = TextEditingController();
  final roomTypeCtl = TextEditingController();
  final priceCtl = TextEditingController();
  final contactCtl = TextEditingController();
  final noteCtl = TextEditingController();
  String? selectedRoomType;
  int? selectedEventId;
  int? selectedHotelId;
  int? selectedRoomTypeId;

  String? selectedFriendGender;
  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to say'];

  File? _image;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        url = config['apiEndpoint'];
      });
    }).catchError((err) {
      log(err.toString());
    });
  }

Future<void> _submitRoomShare() async {
  // final noteRegex = RegExp(r'^[a-zA-Z0-9\s]{2,}$');

  if (selectedFriendGender == null ||
      selectedEventId == null ||
      selectedHotelId == null ||
      selectedRoomType == null ||
      priceCtl.text.isEmpty ||
      contactCtl.text.isEmpty ||
      noteCtl.text.isEmpty) {
    _showAlertDialog(context, "กรุณากรอกข้อมูลให้ครบ");
    return;
  }
bool isValidText(String text) {
  // ต้องมีอย่างน้อย 1 ตัวอักษร a-z A-Z ก-ฮ หรือ ตัวเลข 0-9
  return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
}

if (!isValidText(priceCtl.text) ||
    !isValidText(contactCtl.text) ||
    !isValidText(noteCtl.text)) {
  _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
  return;
}


//   if (!noteRegex.hasMatch(noteCtl.text)) {
//   _showAlertDialog(context,
//     "รูปแบบการเขียนโน้ตไม่ถูกต้อง");
//   return;
// }
  try {
    showLoadingDialog();

    var uri = Uri.parse("$API_ENDPOINT/addroomshare");
    var request = http.MultipartRequest('POST', uri);

    request.fields['userID'] = widget.userId.toString();
    request.fields['gender_restrictions'] = selectedFriendGender!;
    request.fields['eventID'] = selectedEventId.toString();
    request.fields['hotelID'] = selectedHotelId.toString();
    request.fields['typeRoom'] = selectedRoomType!;
    request.fields['price'] = priceCtl.text;
    request.fields['contact'] = contactCtl.text;
    request.fields['note'] = noteCtl.text;
    request.fields['status'] = '0';



    var response = await request.send();
    hideLoadingDialog();

    if (response.statusCode == 201) {
      _showAlertDialog(context, "เพิ่มข้อมูลห้องแชร์สำเร็จ", onOkPressed: () {
        Navigator.pop(context,true);
      });
    } else {
      _showAlertDialog(context, "ไม่สามารถเพิ่มข้อมูลได้");
    }
  } catch (e) {
    hideLoadingDialog();
    _showAlertDialog(context, "อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ");
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
                if (onOkPressed != null) onOkPressed();
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
      builder: (context) => Center(child: CircularProgressIndicator(color: Colors.black)),
    );
  }

  void hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: '$label ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(217, 217, 217, 1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(
      String label, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: '$label ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedValue,
            items: genderOptions.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender,
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(217, 217, 217, 1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Color.fromRGBO(217, 217, 217, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Event ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          DropdownSearch<Map<String, dynamic>>(
            asyncItems: (String filter) async {
              final response = await http.get(Uri.parse("$API_ENDPOINT/event"));
              if (response.statusCode == 200) {
                final List<dynamic> data = json.decode(response.body);
                return data
                    .where((item) => item['eventName']
                        .toString()
                        .toLowerCase()
                        .contains(filter.toLowerCase()))
                    .cast<Map<String, dynamic>>()
                    .toList();
              } else {
                throw Exception("โหลดอีเวนต์ไม่สำเร็จ");
              }
            },
            itemAsString: (item) => item['eventName'],
            selectedItem: selectedEventId != null
                ? {"eventID": selectedEventId, "eventName": eventCtl.text}
                : null,
            onChanged: (value) {
              setState(() {
                eventCtl.text = value?['eventName'] ?? '';
                selectedEventId = value?['eventID'];
              });
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(217, 217, 217, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search event...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Hotel ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          DropdownSearch<String>(
            asyncItems: (String filter) async {
              final response = await http.get(Uri.parse("$API_ENDPOINT/hotel"));
              if (response.statusCode == 200) {
                final List<dynamic> data = json.decode(response.body);
                return data
                    .map((item) => item['hotelName'].toString())
                    .where((name) =>
                        name.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
              } else {
                throw Exception("โหลดศิลปินไม่สำเร็จ");
              }
            },
            selectedItem: hotelCtl.text.isNotEmpty ? hotelCtl.text : null,
            onChanged: (value) async {
              setState(() {
                hotelCtl.text = value ?? '';
                selectedHotelId = null;
                selectedRoomType = null;
              });

              final response = await http.get(Uri.parse("$API_ENDPOINT/hotel"));
              if (response.statusCode == 200) {
                final List data = json.decode(response.body);
                final selected = data.firstWhere(
                  (e) => e['hotelName'] == value,
                  orElse: () => null,
                );
                setState(() {
                  selectedHotelId = selected?['hotelID'];
                });
              }
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(217, 217, 217, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search hotel...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRoomDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Type Room ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          DropdownSearch<String>(
            asyncItems: (String filter) async {
              if (selectedHotelId == null) return [];
              final response = await http.get(
                Uri.parse("$API_ENDPOINT/typeroom?hotelID=$selectedHotelId"),
              );
              if (response.statusCode == 200) {
                final List data = json.decode(response.body);
                return data
                    .map((item) => item['roomName'].toString())
                    .where((name) =>
                        name.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
              } else {
                throw Exception("โหลดประเภทห้องไม่สำเร็จ");
              }
            },
            selectedItem: selectedRoomType,
            onChanged: (value) {
              setState(() {
                selectedRoomType = value ?? '';
                roomTypeCtl.text = value ?? '';
              });
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(217, 217, 217, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search type room...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
              emptyBuilder: (context, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("No Found Type Room",
                      style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Price/Person ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextField(
            controller: priceCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(217, 217, 217, 1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, right: 5),
              child: Text(
                'ราคาต่อคนที่ต้องการจ่าย',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Contact ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(
                    text: '(Instagram, ID Line, Facebook)',
                    style: TextStyle(color: Colors.black, fontSize: 13)),
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextField(
            controller: contactCtl, // แก้ตรงนี้
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(217, 217, 217, 1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.only(top: 5, right: 5),
                child: Text(
                  'Ex : ID Line AAAA ',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Note ',
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextField(
            controller: noteCtl, // แก้ตรงนี้
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(217, 217, 217, 1),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.only(top: 5, right: 5),
                child: Text(
                  'Ex : ไม่สูบบุหรี่, ไม่เสียงดัง,... ',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                )),
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
            'Add Room Share',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No', style: TextStyle(color: Colors.black)),
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
                      child: Text('Yes', style: TextStyle(color: Colors.black)),
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
            SizedBox(height: 30),
            GestureDetector(
              child: Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage('assets/images/Profile.png')
                          as ImageProvider,
                ),
              ),
            ),
            _buildGenderDropdown('Gender Friend', selectedFriendGender,
                (val) => setState(() => selectedFriendGender = val)),
            _buildEventDropdown(),
            _buildHotelDropdown(),
            _buildTypeRoomDropdown(),
            _buildPriceField(),
            _buildContactField(),
            _buildNoteField(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 190, 150, 198),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _submitRoomShare,
                  child: Text('Add',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
