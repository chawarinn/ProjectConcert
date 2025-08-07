import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/EditRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:google_fonts/google_fonts.dart';

class AddRoom extends StatefulWidget {
  final int hotelID;
  final int userId;
  final bool fromAddHotel;
  AddRoom(
      {super.key,
      required this.hotelID,
      required this.userId,
      this.fromAddHotel = false});

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  int _currentIndex = 0;
  var priceCtl = TextEditingController();
  var sizeCtl = TextEditingController();
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
  Map<String, dynamic>? roomData;
  bool isLoadingRoom = false;
  String url = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      fetchRoomData();
      Configuration.getConfig().then((config) {
        url = config['apiEndpoint'];
      }).catchError((err) {
        log(err.toString());
      });

      setState(() {
        isLoading = false;
      });
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
    log('Fetching room data...');

    setState(() {
      isLoadingRoom = true;
      roomData = null;
    });

    final url = Uri.parse('$API_ENDPOINT/rooms?hotelID=${widget.hotelID}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          roomData = {'rooms': data};
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
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
    } finally {
      if (mounted) {
        setState(() {
          isLoadingRoom = false;
        });
      }
    }
  }

  Future<void> addRoom() async {
    final nameRegex =  RegExp(r'^(?=.*[ก-๙a-zA-Z])[ก-๙a-zA-Z0-9]+( [ก-๙a-zA-Z0-9]+)*$');

    if (priceCtl.text.isEmpty ||
        sizeCtl.text.isEmpty ||
        roomNameCtl.text.isEmpty) {
      _showAlertDialog(context, "กรอกข้อมูลไม่ครบ");
      return;
    }
    bool isValidText(String text) {
      // ต้องมีอย่างน้อย 1 ตัวอักษร a-z A-Z ก-ฮ หรือ ตัวเลข 0-9
      return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
    }
      if (!nameRegex.hasMatch(roomNameCtl.text)) {
  _showAlertDialog(context,
    "กรุณาเพิ่มประเภทห้อง/เตียงให้ตรงตามมาตรฐาน");
  return;
}
    if (!isValidText(priceCtl.text) ||
        !isValidText(roomNameCtl.text) ||
        !isValidText(sizeCtl.text)) {
      _showAlertDialog(context, "ข้อมูลไม่ถูกต้อง");
      return;
    }

    if (_image == null) {
      _showAlertDialog(context, "กรุณาเพิ่มรูป");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      ),
    );

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
    request.fields['roomName'] = roomNameCtl.text;
    request.fields['hotelID'] = widget.hotelID.toString();
    request.fields['price'] = priceCtl.text;
    request.fields['size'] = sizeCtl.text;
    request.fields['status'] = '0';

    try {
      var response = await request.send();

      if (context.mounted)
        Navigator.of(context, rootNavigator: true).pop(); // ปิด dialog

      if (response.statusCode == 201) {
        _showAlertDialog(context, "เพิ่มห้องสำเร็จ", onOkPressed: () {
          priceCtl.clear();
          sizeCtl.clear();
          roomNameCtl.clear();
          setState(() {
            _image = null;
          });
          fetchRoomData();
        });
      } else {
        _showAlertDialog(
            context, "เพิ่มห้องไม่สำเร็จ");
      }
    } catch (e) {
      if (context.mounted)
        Navigator.of(context, rootNavigator: true).pop(); // ปิด dialog
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
    return WillPopScope(
    onWillPop: () async {
      if (roomData == null || roomData!['rooms'].isEmpty) {
        _showAlertDialog(context, 'กรุณาเพิ่มห้องอย่างน้อย 1 ห้อง');
        return false;
      }

      if (widget.fromAddHotel) {
        bool? confirmExit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Notification'),
              content: const Text(
                  'คุณยังดำเนินการเพิ่มโรงแรมไม่สำเร็จ กรุณากด Confirm หากต้องการออกจากหน้านี้ ระบบจะทำการลบข้อมูลก่อนหน้านี้ของคุณ'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );

        if (confirmExit != true) return false;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          },
        );

        try {
          final deleteRoomsResponse = await http.delete(Uri.parse(
            '$API_ENDPOINT/deleteallroom?hotelID=${widget.hotelID}',
          ));

          if (deleteRoomsResponse.statusCode != 200) {
            Navigator.of(context).pop();
            return false;
          }

          final deleteHotelResponse = await http.delete(Uri.parse(
            '$API_ENDPOINT/deletehotel?hotelID=${widget.hotelID}',
          ));

          Navigator.of(context).pop();

          if (deleteHotelResponse.statusCode != 200) {
            return false;
          }
        } catch (e) {
          Navigator.of(context).pop();
          return false;
        }
      }

      Navigator.pop(context, true); // pop the screen
      return false; // already manually popped
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(201, 151, 187, 1),
           title: Transform.translate(
            offset: const Offset(-20, 0),
            child: Text(
              'Add Room',
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
            onPressed: () async {
              if (roomData == null || roomData!['rooms'].isEmpty) {
                _showAlertDialog(context, 'กรุณาเพิ่มห้องอย่างน้อย 1 ห้อง');
                return;
              }
              if (widget.fromAddHotel) {
                bool? confirmExit = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Notification'),
                      content: const Text(
                          'คุณยังดำเนินการเพิ่มโรงแรมไม่สำเร็จ กรุณากด Confirm หากต้องการออกจากหน้านี้ ระบบจะทำการลบข้อมูลก่อนหน้านี้ของคุณ'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No',
                              style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
                if (confirmExit != true) return;
      
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  },
                );
      
                try {
                  final deleteRoomsResponse = await http.delete(Uri.parse(
                    '$API_ENDPOINT/deleteallroom?hotelID=${widget.hotelID}',
                  ));
      
                  if (deleteRoomsResponse.statusCode != 200) {
                    Navigator.of(context).pop();
                    return;
                  }
                  final deleteHotelResponse = await http.delete(Uri.parse(
                    '$API_ENDPOINT/deletehotel?hotelID=${widget.hotelID}',
                  ));
      
                  Navigator.of(context).pop();
      
                  if (deleteHotelResponse.statusCode != 200) {
                    return;
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  return;
                }
              }
              Navigator.pop(context, true);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                if (roomData == null || roomData!['rooms'].isEmpty) {
                  _showAlertDialog(context, 'กรุณาเพิ่มห้องอย่างน้อย 1 ห้อง');
                  return;
                }
                if (widget.fromAddHotel) {
                  bool? confirmExit = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Notification'),
                        content: const Text(
                            'คุณยังดำเนินการเพิ่มโรงแรมไม่สำเร็จ กรุณากด Confirm หากต้องการออกจากหน้านี้ ระบบจะทำการลบข้อมูลก่อนหน้านี้ของคุณ'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No',
                                style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
      
                  if (confirmExit != true) return;
      
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    },
                  );
      
                  try {
                    final deleteRoomsResponse = await http.delete(Uri.parse(
                      '$API_ENDPOINT/deleteallroom?hotelID=${widget.hotelID}',
                    ));
      
                    if (deleteRoomsResponse.statusCode != 200) {
                      Navigator.of(context).pop();
                      return;
                    }
                    final deleteHotelResponse = await http.delete(Uri.parse(
                      '$API_ENDPOINT/deletehotel?hotelID=${widget.hotelID}',
                    ));
      
                    Navigator.of(context).pop();
      
                    if (deleteHotelResponse.statusCode != 200) {
                      return;
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    return;
                  }
                }
      
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
            if (roomData == null || roomData!['rooms'].isEmpty) {
              _showAlertDialog(context, 'กรุณาเพิ่มห้องอย่างน้อย 1 ห้อง');
              return;
            }
            if (widget.fromAddHotel) {
              bool? confirmExit = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Notification'),
                    content: const Text(
                        'คุณยังดำเนินการเพิ่มโรงแรมไม่สำเร็จ กรุณากด Confirm หากต้องการออกจากหน้านี้ ระบบจะทำการลบข้อมูลก่อนหน้านี้ของคุณ'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
      
              if (confirmExit != true) return;
      
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                },
              );
      
              try {
                final deleteRoomsResponse = await http.delete(Uri.parse(
                  '$API_ENDPOINT/deleteallroom?hotelID=${widget.hotelID}',
                ));
      
                if (deleteRoomsResponse.statusCode != 200) {
                  Navigator.of(context).pop();
                  return;
                }
                final deleteHotelResponse = await http.delete(Uri.parse(
                  '$API_ENDPOINT/deletehotel?hotelID=${widget.hotelID}',
                ));
      
                Navigator.of(context).pop();
      
                if (deleteHotelResponse.statusCode != 200) {
                  return;
                }
              } catch (e) {
                Navigator.of(context).pop();
                return;
              }
            }
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeHotel(userId: widget.userId),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileHotel(userId: widget.userId),
                  ),
                );
                break;
            }
          },
          backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
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
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                            : const AssetImage(
                                                'assets/images/album.jpg',
                                              ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: _image != null ? 0 : 30,
                                    right: _image != null ? 0 : 30,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            232, 234, 237, 1),
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
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Type Room',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  const SizedBox(height: 1),
                                  Autocomplete<String>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      return nameRoomList.where((String option) {
                                        return option.toLowerCase().contains(
                                            textEditingValue.text.toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      roomNameCtl.text = selection;
                                    },
                                    fieldViewBuilder: (context,
                                        textEditingController,
                                        focusNode,
                                        onFieldSubmitted) {
                                      return TextFormField(
                                        controller: roomNameCtl,
                                        focusNode: focusNode,
                                        onFieldSubmitted: (value) =>
                                            onFieldSubmitted(),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color.fromRGBO(
                                              217, 217, 217, 1),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 15),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                              padding: const EdgeInsets.only(
                                  top: 5, right: 10, left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  const SizedBox(height: 1),
                                  TextField(
                                    controller: priceCtl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
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
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, right: 10, left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bed Size',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  const SizedBox(height: 1),
                                  DropdownButtonFormField<String>(
                                    value: sizeCtl.text.isNotEmpty
                                        ? sizeCtl.text
                                        : null,
                                    items: bedSizeValues.keys
                                        .map((size) => DropdownMenuItem(
                                              value: size,
                                              child: Text(size),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        sizeCtl.text = value!;
                                        double numericSize =
                                            bedSizeValues[value]!;
                                        print(
                                            'Selected bed size in number: $numericSize');
                                      });
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
                                  onPressed: addRoom,
                                  child: const Text(
                                    "Next",
                                    style: TextStyle(color: Colors.white,fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: isLoadingRoom
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : (roomData == null ||
                                          roomData!['rooms'] == null ||
                                          roomData!['rooms'].isEmpty)
                                      ? SizedBox.shrink()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: roomData!['rooms'].length,
                                          itemBuilder: (context, index) {
                                            final room =
                                                roomData!['rooms'][index];
                                            return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                child: ListTile(
                                                  leading: room['photo'] != null
                                                      ? Image.network(
                                                          room['photo'],
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : const Icon(Icons.room),
                                                  title: Text(room['roomName'] ??
                                                      'ชื่อห้องไม่ระบุ'),
                                                  subtitle: Text(
                                                      'ราคา: ${room['price'].toString() ?? '-'} บาท\nขนาดเตียง: ${room['size'].toString() ?? '-'} ฟุต'),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: Colors.blue,
                                                            size: 26),
                                                        onPressed: () async {
                                                          final result =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      EditRoom(
                                                                userId:
                                                                    widget.userId,
                                                                roomID: room[
                                                                    'roomID'],
                                                                hotelID: widget
                                                                    .hotelID,
                                                              ),
                                                            ),
                                                          );
                                                          if (result == true) {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                            fetchRoomData();
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete,
                                                            color: Colors.red,
                                                            size: 28),
                                                        onPressed: () async {
                                                          final confirm =
                                                              await showDialog<
                                                                  bool>(
                                                            context: context,
                                                            builder: (context) =>
                                                                AlertDialog(
                                                              title: Text(
                                                                  'Notification'),
                                                              content: Text(
                                                                  'คุณแน่ใจว่าต้องการลบห้องนี้หรือไม่?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          false),
                                                                  child: Text(
                                                                      'No',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black)),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          true),
                                                                  child: Text(
                                                                      'Yes',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black)),
                                                                ),
                                                              ],
                                                            ),
                                                          );
      
                                                          if (confirm == true) {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) =>
                                                                      Dialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                child: Center(
                                                                    child:
                                                                        CircularProgressIndicator(color: Colors.black)),
                                                              ),
                                                            );
      
                                                            try {
                                                              final response =
                                                                  await http
                                                                      .delete(Uri
                                                                          .parse(
                                                                '$API_ENDPOINT/deleteroom?roomID=${room['roomID']}',
                                                              ));
      
                                                              if (context.mounted)
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
      
                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                if (context
                                                                    .mounted) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                        content: Text(
                                                                            "ลบเรียบร้อยแล้ว")),
                                                                  );
                                                                  await fetchRoomData();
                                                                }
                                                              } else {
                                                                throw Exception(
                                                                    "ลบไม่สำเร็จ: ${response.body}");
                                                              }
                                                            } catch (e) {
                                                              if (context.mounted)
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              if (context
                                                                  .mounted) {
                                                                ScaffoldMessenger
                                                                        .of(context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          "เกิดข้อผิดพลาด: $e")),
                                                                );
                                                              }
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                          },
                                        ),
                            ),
                            if (widget.fromAddHotel &&
                                roomData != null &&
                                roomData!['rooms'] != null &&
                                roomData!['rooms'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HomeHotel(userId: widget.userId),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
