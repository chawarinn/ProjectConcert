import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Location.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/AddPostHotelResponse.dart';
import 'package:get_storage/get_storage.dart';

class AddHotel extends StatefulWidget {
  int userId;
  AddHotel({super.key, required this.userId});

  @override
  State<AddHotel> createState() => _AddHotelState();
}

class _AddHotelState extends State<AddHotel> {
  @override
  var fullnameCtl = TextEditingController();
  var fullname2Ctl = TextEditingController();
  var priceCtl = TextEditingController();
  var phoneCtl = TextEditingController();
  var contactCtl = TextEditingController();
  var locationCtl = TextEditingController();
  var detailCtl = TextEditingController();
  File? _image;
  String url = '';
  late AddHotelPostResponse hotelData;
  bool _isFocused = false;
  final FocusNode _FocusNode = FocusNode();
  String? selectedLocation;
  double? selectedLatitude;
  double? selectedLongitude;
  int _currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

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

    // โหลด config API
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
  }

  @override
  void dispose() {
    _FocusNode.dispose();
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
      // _showAlertDialog(context, "Image selection failed: $e");
    }
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
        locationCtl.text = result['Address'] ?? '';
      });
      log('Selected Location: $selectedLocation');
    }
  }

  Future<void> addhotel(BuildContext context) async {
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    final nameRegex = RegExp(r'^(?=.*[ก-๙])[ก-๙]+( [ก-๙]+)*$');
    final name2Regex = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9]+( [a-zA-Z0-9]+)*$');

    if (fullnameCtl.text.isEmpty ||
        fullname2Ctl.text.isEmpty ||
        priceCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        contactCtl.text.isEmpty ||
        locationCtl.text.isEmpty ||
        selectedLatitude.toString().isEmpty) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }
     if (_image == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูป");
      return;
    }
    bool isValidText(String text) {
  return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
}

if (!isValidText(fullnameCtl.text) ||
    !isValidText(fullname2Ctl.text) ||
    !isValidText(phoneCtl.text) ||
    !isValidText(contactCtl.text) ||
    !isValidText(locationCtl.text) ||
    !isValidText(priceCtl.text)) {
  _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
  return;
}
    if (!nameRegex.hasMatch(fullnameCtl.text)) {
  _showAlertDialog(context,
    "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
  return;
}
 if (!name2Regex.hasMatch(fullname2Ctl.text)) {
  _showAlertDialog(context,
    "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
  return;
}
    if (!phoneRegex.hasMatch(phoneCtl.text)) {
      _showAlertDialog(context, "กรุณาใส่หมายเลขโทรศัพท์ให้ถูกต้อง");
      return;
    }

    var uri = Uri.parse("$API_ENDPOINT/addhotel");
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

    request.fields['hotelName'] = fullnameCtl.text;
    request.fields['hotelName2'] = fullname2Ctl.text;
    request.fields['startingPrice'] = priceCtl.text;
    request.fields['phone'] = phoneCtl.text;
    request.fields['contact'] = contactCtl.text;
    request.fields['detail'] = detailCtl.text;
    request.fields['location'] = locationCtl.text;
    request.fields['lat'] = selectedLatitude?.toString() ?? '';
    request.fields['long'] = selectedLongitude?.toString() ?? '';
    request.fields['userID'] = widget.userId.toString() ?? '';

    try {
      showLoadingDialog();
      var response = await request.send();
      hideLoadingDialog();
      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        log(data);
        hotelData = addHotelPostResponseFromJson(data);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRoom(
              hotelID: hotelData.hotelId,
              userId: widget.userId,
              fromAddHotel: true
            ),
          ),
        );
      } else {}
    } catch (e) {
      hideLoadingDialog();
      showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Notification'),
      content: Text('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  },
);
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
            'Add Hotel',
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
                ),
              );
            },
          ),
        ],
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
        MaterialPageRoute(builder: (context) =>  HomeHotel(userId: widget.userId)),
      );
      break;
    case 1:
      await box.write('lastVisitedPage', 'profileHotel');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>ProfileHotel(userId: widget.userId)),
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
                                : const AssetImage('assets/images/album.jpg')
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
                            icon: Icon(
                              _image != null ? Icons.edit : Icons.add,
                              color: Colors.black,
                            ),
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
                            text: 'Hotel Name (Thai) ',
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
                            text: 'Hotel Name (Eng) ',
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
                          controller: fullname2Ctl,
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
                            text: 'Starting Price ',
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
                          controller: priceCtl,
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
                        const SizedBox(height: 3),
                        TextField(
                          controller: phoneCtl,
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
                            text: 'Contact (Facebook)  ',
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
                          controller: contactCtl,
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
                            text: 'Detail ',
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
                          controller: detailCtl,
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
                              'Ex. อาหารเช้า, ฟิตเนส, โทรทัศน์จอ,...',
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
                          controller: locationCtl,
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
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child:  Row(
                                children: [
                                  Text("เลือกตำแหน่ง",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12)),
                                  Icon(
                                    Icons.add_location_alt_rounded,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
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
                          onPressed: () => addhotel(context),
                          child: Text(
                            "Next",
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
