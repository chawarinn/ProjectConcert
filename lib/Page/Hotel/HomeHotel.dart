// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/EditHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:http/http.dart' as http;

class HomeHotel extends StatefulWidget {
  final int userId;
  const HomeHotel({super.key, required this.userId});

  @override
  State<HomeHotel> createState() => _HomeHotelState();
}

class _HomeHotelState extends State<HomeHotel> {
  int _currentIndex = 0;
  bool _isLoading = false;
  late String url;

  List<UserHotelGetResponse> hotels = [];
  List<UserHotelGetResponse> filteredHotels = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });

    _fetchAllHotels();
  }

  Future<void> _fetchAllHotels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/hotelhome?userID=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        List<UserHotelGetResponse> loadedHotels =
            jsonData.map((e) => UserHotelGetResponse.fromJson(e)).toList();

        setState(() {
          hotels = loadedHotels;
          filteredHotels = loadedHotels;
        });
      } else {
        log('Failed to load hotels: ${response.statusCode}');
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20
          ),
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
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileHotel(userId: widget.userId)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : hotels.isEmpty
              ? Center(
                  child: Text(
                    'Add your Hotel',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Delete / Update',
                          style: TextStyle(fontSize: 25)),
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredHotels.length,
                      itemBuilder: (context, index) {
                        return buildHotelCard(
                          context,
                          filteredHotels[index],
                          _fetchAllHotels,
                          widget.userId,
                        );
                      },
                    ),
                        const SizedBox(height: 60),
                  ]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddHotel(userId: widget.userId),
            ),
          );
          if (result == true) {
            _fetchAllHotels();
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}

Widget buildHotelCard(
  BuildContext context,
  UserHotelGetResponse hotel,
  Future<void> Function() onHotelDeleted,
  int userId,
) {
  return Card(
    color: Colors.grey[200],
    margin: EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hotel.hotelName ?? '',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 4),
                        Text(
                          '${hotel.totalPiont ?? 0}/',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              Text(hotel.hotelName2 ?? '',
              style: TextStyle(fontSize: 15)),
          SizedBox(height: 8),
          if ( hotel.hotelPhoto != null)
            Image.network(
               hotel.hotelPhoto,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 8),
           Text('ราคา : เริ่มต้น ${hotel.startingPrice} บาท'),
           Text('ที่ตั้ง : ${hotel.location}'),
            Text('โทรศัพท์ : ${hotel.phone}'),
             Text('Facebook : ${hotel.contact}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon:
                    Icon(Icons.edit, color: Colors.teal, size: 28),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Edithotel(
                        userId: userId,
                        hotelID: hotel.hotelId,
                      ),
                    ),
                  );
                  if (result == true) {
                    await onHotelDeleted();
                  }
                },
              ),
             IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 28),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notification'),
                      content: Text('คุณแน่ใจว่าต้องการลบโรงแรมนี้หรือไม่?'),
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
                      builder: (_) =>
                          Center(child: CircularProgressIndicator(color: Colors.black)),
                    );

                    try {
                      final response = await http.delete(Uri.parse(
                        '$API_ENDPOINT/deletehotel?hotelID=${hotel.hotelId}',
                      ));
                      Navigator.pop(context); // close loading

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("ลบเรียบร้อยแล้ว")),
                        );
                        await onHotelDeleted();
                      } else {
                        throw Exception("ลบไม่สำเร็จ: ${response.body}");
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
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
   
  );
}
