import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';  
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/Location.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/Page/Restaurant/HomeRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/ProfileRestaurant.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/AddPostHotelResponse.dart';

class AddRestaurant extends StatefulWidget {
  int userId;
  AddRestaurant({super.key,  required this.userId});

  @override
  State<AddRestaurant> createState() => _AddRestaurantState();
}

class _AddRestaurantState extends State<AddRestaurant> {
  @override
    int _currentIndex = 0;
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

  String? selectedLocation;
  double? selectedLatitude;
  double? selectedLongitude;


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
    if (fullnameCtl.text.isEmpty ||
        fullname2Ctl.text.isEmpty ||
        priceCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        contactCtl.text.isEmpty ||
        locationCtl.text.isEmpty||
        selectedLatitude.toString().isEmpty) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }

    if (_image == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูป");
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

    try {
      var response = await request.send();

      if (response.statusCode == 201) {
        var data = await response.stream.bytesToString();
        log(data);
       hotelData = addHotelPostResponseFromJson(data); // Now hotelData is initialized

       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRoom(hotelID: hotelData.hotelId), // Pass hotelId from hotelData
        ),
      );

      } else {

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
        title:  Text(
          'Add Hotel',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                    content: const Text('คุณต้องการออกจากระบบ?'),
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
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const homeLogoPage()));
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
      body: SingleChildScrollView(
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
              : const AssetImage('assets/images/album.jpg') as ImageProvider,
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
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: _pickImage,
        ),
      ),
    ),
  ],
)

            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hotel Name',
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
                  Text(
                    'Hotel Name (Eng)',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: fullname2Ctl,
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
                  Text(
                    'Starting Price',
                    style: TextStyle(fontSize: 18, color: Colors.black),
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
                    'Contact (Facebook)',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: contactCtl,
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
                    'Detail',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: detailCtl,
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
                    'Address',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  TextField(
                    controller: locationCtl,
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
              child: Row(
                children: [
                  const Spacer(),
                  if (selectedLocation != null) ...[
                    Text(
                      selectedLocation!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
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
                    onPressed: () => addhotel(context),
                    child:  Text(
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
