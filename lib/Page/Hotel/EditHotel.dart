import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Location.dart';
import 'package:project_concert_closeiin/Page/Hotel/Photohotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class Edithotel extends StatefulWidget {
  int userId;
  int hotelID;
  Edithotel({super.key, required this.userId, required this.hotelID});

  @override
  State<Edithotel> createState() => _AddHotelState();
}

class _AddHotelState extends State<Edithotel> {
  @override
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
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
  Map<String, dynamic>? hotelData;
  Map<String, dynamic>? originalHotelData;
  String? _photo;

  @override
  void initState() {
    super.initState();
    fetchHotelData();

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

  Future<void> fetchHotelData() async {
    final url = Uri.parse('$API_ENDPOINT/hotels?hotelID=${widget.hotelID}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hotelData = data;
          originalHotelData = Map<String, dynamic>.from(data);
          _nameController.text = data['hotelName'] ?? '';
          _name2Controller.text = data['hotelName2'] ?? '';
          _priceController.text = data['startingPrice']?.toString() ?? '';
          _phoneController.text = data['phone'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _detailController.text = data['detail'] ?? '';
          _locationController.text = data['location'] ?? '';
          selectedLatitude = data['lat'];
          selectedLongitude = data['long'];
          selectedLocation = '${data['lat']}, ${data['long']}';
          _photo = data['hotelPhoto'];
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
    if (originalHotelData == null) return true;

    final originalLat = originalHotelData!['lat']?.toString() ?? '';
    final originalLong = originalHotelData!['long']?.toString() ?? '';

    return _nameController.text != (originalHotelData!['hotelName'] ?? '') ||
        _name2Controller.text != (originalHotelData!['hotelName2'] ?? '') ||
        _priceController.text !=
            (originalHotelData!['startingPrice']?.toString() ?? '') ||
        _phoneController.text != (originalHotelData!['phone'] ?? '') ||
        _contactController.text != (originalHotelData!['contact'] ?? '') ||
        _detailController.text != (originalHotelData!['detail'] ?? '') ||
        _locationController.text != (originalHotelData!['location'] ?? '') ||
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
    final nameRegex = RegExp(r'^(?=.*[ก-๙])[ก-๙]+( [ก-๙]+)*$');
    final name2Regex = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9]+( [a-zA-Z0-9]+)*$');
    if (_nameController.text.isEmpty ||
        _name2Controller.text.isEmpty ||
        _priceController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _detailController.text.isEmpty ||
        _locationController.text.isEmpty ||
        selectedLatitude == null ||
        selectedLongitude == null ||
        _image != null) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }
    bool isValidText(String text) {
      return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
    }

    if (!isValidText(_nameController.text) ||
        !isValidText(_name2Controller.text) ||
        !isValidText(_priceController.text) ||
        !isValidText(_contactController.text) ||
        !isValidText(_detailController.text) ||
        !isValidText(_locationController.text)) {
      _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
      return;
    }
    if (!nameRegex.hasMatch(_nameController.text)) {
      _showAlertDialog(context, "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
      return;
    }
    if (!name2Regex.hasMatch(_name2Controller.text)) {
      _showAlertDialog(context, "กรุณาเพิ่มชื่อให้ตรงตามมาตรฐาน");
      return;
    }
    if (!phoneRegex.hasMatch(_phoneController.text)) {
      _showAlertDialog(context, "กรุณาใส่หมายเลขโทรศัพท์ให้ถูกต้อง");
      return;
    }
    final uri = Uri.parse('$API_ENDPOINT/edithotel');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['hotelName'] = _nameController.text;
    request.fields['hotelName2'] = _name2Controller.text;
    request.fields['startingPrice'] = _priceController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['contact'] = _contactController.text;
    request.fields['detail'] = _detailController.text;
    request.fields['location'] = _locationController.text;
    request.fields['lat'] = selectedLatitude?.toString() ?? '';
    request.fields['long'] = selectedLongitude?.toString() ?? '';
    request.fields['hotelID'] = widget.hotelID.toString();

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
            content: Text('ไม่สามารถโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง'),
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
            'Edit Hotel',
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
              child: CircularProgressIndicator(color: Colors.black),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(right: 30, top: 10),
                  //     child: Container(
                  //       width: 50,
                  //       height: 50,
                  //       decoration: BoxDecoration(
                  //         color: const Color.fromRGBO(232, 234, 237, 1),
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Stack(
                  //         children: [
                  //           Center(
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: const [
                  //                 Icon(Icons.bed,
                  //                     color: Colors.black, size: 20),
                  //                 Text(
                  //                   "Edit",
                  //                   style: TextStyle(
                  //                       fontSize: 10, color: Colors.black),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),

                  //           // const Positioned(
                  //           //   top: 0,
                  //           //   right: 0,
                  //           //   child: Icon(
                  //           //     Icons.edit,
                  //           //     size: 14,
                  //           //     color: Colors.black,
                  //           //   ),
                  //           // ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                          controller: _name2Controller,
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
                          controller: _phoneController,
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
                          controller: _contactController,
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
                          controller: _detailController,
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
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Photohotel(
                                      hotelID: widget.hotelID,
                                      userId: widget.userId)),
                            );
                              if (result == true) {
                                setState(() {
                                  isLoading = true;
                                });
                                fetchHotelData();
                              }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/album.jpg',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              const Positioned(
                                bottom: 13,
                                child: Text(
                                  'Photo Albums',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddRoom(
                                      hotelID: widget.hotelID,
                                      userId: widget.userId)),
                            );
                              if (result == true) {
                                setState(() {
                                  isLoading = true;
                                });
                                fetchHotelData();
                              }
                          },
                          child: Container(
                            width: 150,
                            height: 195,
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.bed,
                                  color: Color.fromARGB(202, 0, 0, 0),
                                  size: 150,
                                ),
                                const Positioned(
                                  bottom: 10,
                                  child: Text(
                                    'Edit Room',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
