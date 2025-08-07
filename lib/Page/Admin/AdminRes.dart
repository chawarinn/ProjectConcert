import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminArtist.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminEvent.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminProfile.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'dart:async';
import 'dart:io';
import 'package:get_storage/get_storage.dart';

class AdminRes extends StatefulWidget {
  final int userId;
  const AdminRes({super.key, required this.userId});

  @override
  State<AdminRes> createState() => _AdminResState();
}

class _AdminResState extends State<AdminRes> {
  int _currentIndex = 4;
  bool _isLoading = false;
  late String url;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> Res = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      print(err);
    });
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/Restaurant');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          Res = json.decode(response.body);
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRes = Res.where((res) {
      final name = (res['resName'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Restaurant',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20)),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:
                            Text('No', style: TextStyle(color: Colors.black))),
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
       bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
  final box = GetStorage();
  switch (index) {
    case 0:
      await box.write('lastVisitedPage', 'home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeAdmin(userId: widget.userId)),
      );
      break;
      case 1:
      await box.write('lastVisitedPage', 'event');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  AdminEvent(userId: widget.userId)),
      );
      break;
    case 2:
      await box.write('lastVisitedPage', 'addartist');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>AdminArtistPage(userId: widget.userId)),
      );
      break;
     case 3:
      await box.write('lastVisitedPage', 'hotel');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>AdminHotelPage(userId: widget.userId)),
      );
      break;
     case 4:
      await box.write('lastVisitedPage', 'res');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>AdminRes(userId: widget.userId)),
      );
      break;
       case 5:
      await box.write('lastVisitedPage', 'profileAdmin');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>ProfileAdmin(userId: widget.userId)),
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
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.ticket), label: 'Event'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music), label: 'Artist'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotel'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.utensils), label: 'Restaurant'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)))
              : filteredRes.isEmpty
                  ? Expanded(
                      child: Center(
                          child:
                              Text('No Hotel', style: TextStyle(fontSize: 18))))
                  : Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredRes.length,
                        itemBuilder: (context, index) {
                          return buildCard(
                            context,
                            filteredRes[index],
                            _fetchAll,
                            widget.userId,
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

Widget buildCard(
  BuildContext context,
  dynamic res,
  Future<void> Function() onUpdated,
  int userId,
) {
  return Card(
    color: Colors.grey[200],
    margin: EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: res['resPhoto'] != null
                ? Image.network(
                    res['resPhoto'],
                    width: 120,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 150,
                        color: Colors.grey[400],
                        child: Icon(Icons.image, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    width: 120,
                    height: 150,
                    color: Colors.grey[400],
                    child: Icon(Icons.image, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res['resName'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "ประเภทอาหาร : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: res['type'] ?? '',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "เวลา : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: res['open'] ?? '',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: " - ",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: res['close'] ?? '',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: " น. ",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "ที่ตั้ง : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: res['location'] ?? '',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                if (res['distance'] != null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "ระยะทาง : ",
                          style: TextStyle(fontSize: 12),
                        ),
                        TextSpan(
                          text: res['distance'].toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " กม.",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "ติดต่อ : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: res['contact'] ?? 'No Contact',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: res['contact'] == null
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 35),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Notification'),
                            content: Text('ต้องการลบร้านอาหารนี้หรือไม่?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('No',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Yes',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black)),
                          );

                          try {
                            final response = await http.delete(Uri.parse(
                              '$API_ENDPOINT//deleterestaurant?resID=${res['resID']}',
                            ));
                            Navigator.pop(context);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                              );
                              await onUpdated();
                            } else {
                              throw Exception('ลบไม่สำเร็จ: ${response.body}');
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
