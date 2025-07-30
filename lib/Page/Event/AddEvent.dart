import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Event/AddArtist.dart';
import 'package:project_concert_closeiin/Page/Event/HomeEvent.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Event/SelectArtist.dart';
import 'package:project_concert_closeiin/Page/Event/Location.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:flutter/foundation.dart';

class AddEvent extends StatefulWidget {
  int userId;
  AddEvent({super.key, required this.userId});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  @override
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _linkticketController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _ltimeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  String url = '';
  int? selectedArtistId;
  int? selectedTypeId;
  bool _isFocused = false;
  final FocusNode _FocusNode = FocusNode();
  String? selectedLocation;
  double? selectedLatitude;
  double? selectedLongitude;
  int _currentIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? eventData;
  String? _photo;
  String _selectedIsoDate = '';

  final List<String> nameList = [
    'IMPACT Arena Muang Thong Thani',
    'UNION HALL | UNION MALL ',
    'UOB LIVE, EMSPHERE',
    'Rajamangala National Stadium',
    'Thunder Dome, Muang Thong Thani',
    'Muangthai Rachadalai Theatre',
    'TRUE ICON HALL, 7th FLOOR, ICONSIAM',
    'Paragon Hall',
    'Central World Live House '
  ];

  @override
  void dispose() {
    _displayController.dispose();
    _FocusNode.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatDateThai(DateTime date) {
    const thaiMonthsFull = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return '${date.day} ${thaiMonthsFull[date.month]} ${date.year}';
  }

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

  void _showAddResultDialog() async {
  if (_nameController.text.trim().isEmpty ||
      _displayController.text.trim().isEmpty ||
      _timeController.text.trim().isEmpty ||
      _ltimeController.text.trim().isEmpty ||
      _typeController.text.trim().isEmpty ||
      _linkticketController.text.trim().isEmpty ||
      _locationController.text.trim().isEmpty ||
      selectedLatitude == null ||
      selectedLongitude == null) {
    _showAlertDialog(context, "กรุณากรอกข้อมูลให้ครบถ้วน");
    return;
  }
  if (_image == null) {
  _showAlertDialog(context, "กรุณาเลือกรูปอีเว้นท์");
  return;
}
  if (eventData == null ||
      eventData!['artists'] == null ||
      (eventData!['artists'] as List).isEmpty) {
    _showAlertDialog(context, "กรุณาเลือกศิลปินอย่างน้อย 1 คน");
    return;
  }

  final ticketUrl = _linkticketController.text.trim();
  final urlPattern = RegExp(r"^https?:\/\/.+");
  if (!urlPattern.hasMatch(ticketUrl)) {
    _showAlertDialog(context,
        "กรุณากรอกลิงก์ให้ถูกต้อง โดยต้องเริ่มต้นด้วย http:// หรือ https://");
    return;
  }
   try {
    final startTimeParts = _timeController.text.split(":");
    final endTimeParts = _ltimeController.text.split(":");

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
      _showAlertDialog(context, "เนื่องจากเวลาสิ้นสุดคือ ${_ltimeController.text} น. เวลาเริ่มต้นและเวลาสิ้นสุดไม่สอดคล้องกัน ");
      return;
    }
  } catch (e) {
    _showAlertDialog(context, "รูปแบบเวลาไม่ถูกต้อง");
    return;
  }

  final uri = Uri.parse('$API_ENDPOINT/addEvent');
  final request = http.MultipartRequest('POST', uri);

  request.fields['eventName'] = _nameController.text;

  String formattedDateForDB = '';
  if (_selectedIsoDate.isNotEmpty) {
    DateTime parsedDate = DateTime.parse(_selectedIsoDate);
    formattedDateForDB = '${parsedDate.year.toString().padLeft(4, '0')}-'
        '${parsedDate.month.toString().padLeft(2, '0')}-'
        '${parsedDate.day.toString().padLeft(2, '0')}';
  }
  request.fields['date'] = _selectedIsoDate;
  request.fields['time'] = _timeController.text;
  request.fields['ltime'] = _ltimeController.text;
  request.fields['typeEventID'] = selectedTypeId.toString();
  request.fields['linkticket'] = _linkticketController.text;
  request.fields['location'] = _locationController.text;
  request.fields['lat'] = selectedLatitude?.toString() ?? '';
  request.fields['long'] = selectedLongitude?.toString() ?? '';
  request.fields['userID'] = widget.userId.toString();  // ✅ สำคัญ

  if (eventData!['artists'] != null) {
  List<int> artistIDs = (eventData!['artists'] as List)
      .map((artist) => artist['artistID'] as int)
      .toList();
        print('Artist IDs: $artistIDs');  // ✅ ปริ้นค่าศิลปินที่เลือก
  request.fields['artists'] = jsonEncode(artistIDs);
}


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
    builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.black)),
  );

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    Navigator.pop(context);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showAlertDialog(
        context,
        'เพิ่มอีเวนต์สำเร็จ',
        onOkPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeEvent(userId: widget.userId),
            ),
            (route) => false,
          );
        },
      );
    } else {
      _showAlertDialog(
          context, "เพิ่มข้อมูลไม่สำเร็จ (${response.statusCode})");
    }
  } catch (e) {
    Navigator.pop(context);
    _showAlertDialog(context, 'เกิดข้อผิดพลาด: $e');
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
            'Add Event',
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
                    builder: (context) =>
                        HomeEvent(userId : widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AddArtistPage(userId: widget.userId)),
              );
              break;
               case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileEvent(userId: widget.userId)),
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
            icon: Icon(Icons.library_music),
            label: 'Artist',
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
                            icon: Icon(_image != null ? Icons.edit : Icons.add,
                                color: Colors.black),
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
                            text: 'Event Name ',
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
                            text: 'Event Type ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownSearch<Map<String, dynamic>>(
                          asyncItems: (String filter) async {
                            final response = await http
                                .get(Uri.parse("$API_ENDPOINT/typeEvent"));
                            if (response.statusCode == 200) {
                              final List<dynamic> data =
                                  json.decode(response.body);
                              return data
                                  .where((item) => item['typeEventName']
                                      .toString()
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()))
                                  .cast<Map<String, dynamic>>()
                                  .toList();
                            } else {
                              throw Exception("โหลดTypeEventไม่สำเร็จ");
                            }
                          },
                          itemAsString: (item) => item['typeEventName'] ?? '',
                          selectedItem: selectedTypeId != null &&
                                  _typeController.text.isNotEmpty
                              ? {
                                  "typeEventID": selectedTypeId,
                                  "typeEventName": _typeController.text,
                                }
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _typeController.text =
                                  value?['typeEventName'] ?? '';
                              selectedTypeId = value?['typeEventID'];
                            });
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromRGBO(217, 217, 217, 1),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            baseStyle: const TextStyle(
                              fontSize: 16, // เพิ่มขนาดตัวหนังสือ
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: const InputDecoration(
                                hintText: "Search...",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                              ),
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
                            text: 'Date ',
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
                          controller: _displayController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              _selectedIsoDate =
                                  '${pickedDate.year.toString().padLeft(4, '0')}-'
                                  '${pickedDate.month.toString().padLeft(2, '0')}-'
                                  '${pickedDate.day.toString().padLeft(2, '0')}';

                              _displayController.text =
                                  _formatDateThai(pickedDate);
                              setState(() {});
                            }
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Start Time ',
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
                          controller: _timeController,
                          readOnly: true,
                          onTap: () => _selectTime(context, _timeController),
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
                            text: 'End Time ',
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
                          controller: _ltimeController,
                          readOnly: true,
                          onTap: () => _selectTime(context, _ltimeController),
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
                            text: 'Link Ticket ',
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
                          controller: _linkticketController,
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
                              'Ex. https://www.theconcert.com/.../...',
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
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return nameList.where((String option) {
                              return option.contains(textEditingValue.text);
                            });
                          },
                          onSelected: (String selection) {
                            _locationController.text = selection;
                          },
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            controller.text = _locationController.text;

                            controller.addListener(() {
                              _locationController.text = controller.text;
                            });

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              onFieldSubmitted: (value) {
                                onFieldSubmitted();
                                _locationController.text = value;
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Artist ',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (eventData != null &&
                                eventData!['artists'] != null &&
                                (eventData!['artists'] as List).isNotEmpty)
                              ...eventData!['artists'].map<Widget>((artist) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            artist['artistPhoto'] ?? '',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          artist['artistName'] ?? '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            eventData!['artists'].removeWhere(
                                                (a) =>
                                                    a['artistID'] ==
                                                    artist['artistID']);
                                            eventData!['artists'] = List.from(
                                                eventData!['artists']);
                                          });
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.grey[200],
                                          child: const Icon(Icons.close,
                                              color: Colors.red, size: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            GestureDetector(
                              onTap: () async {
                                List<String> existingArtistIds = [];
                                if (eventData != null &&
                                    eventData!['artists'] != null) {
                                  existingArtistIds = eventData!['artists']
                                      .map<String>((artist) =>
                                          artist['artistID'].toString())
                                      .toList();
                                }

                                final selectedArtistIds = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectArtistPage(
                                      userId: widget.userId,
                                      existingArtistIds: existingArtistIds,
                                    ),
                                  ),
                                );

                                if (selectedArtistIds != null) {
                                  final response = await http
                                      .get(Uri.parse('$API_ENDPOINT/artist'));
                                  if (response.statusCode == 200) {
                                    final List<dynamic> allArtists =
                                        json.decode(response.body);
                                    List<dynamic> selectedArtists = allArtists
                                        .where((artist) =>
                                            selectedArtistIds.contains(
                                                artist['artistID'].toString()))
                                        .toList();

                                    setState(() {
                                      eventData ??=
                                          {}; // เผื่อ eventData ยังเป็น null
                                      eventData!['artists'] = selectedArtists;
                                    });
                                  }
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: const AssetImage(
                                        'assets/images/Person.webp'),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: const Color.fromRGBO(
                                          232, 234, 237, 1),
                                      child: Icon(Icons.add,
                                          color: Colors.black, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          // onPressed: () => (),
                          onPressed: () => _showAddResultDialog(),
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
