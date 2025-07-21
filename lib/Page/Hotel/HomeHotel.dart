// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/EditHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'dart:convert';
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
      log('Error fetching hotels: $e');
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
          ? Center(child: CircularProgressIndicator())
          : hotels.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Column(
                    children: [
                      const Text(
                        'เพิ่มข้อมูลโรงแรมของคุณ',
                        style: TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 163),
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 150,
                          child: TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddHotel(userId: widget.userId),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  _isLoading = false;
                                });
                                _fetchAllHotels();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(117, 43, 161, 141),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 30,
                                color: Color.fromARGB(255, 62, 61, 61),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
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
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 100,
                          child: TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddHotel(userId: widget.userId),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  _isLoading = false;
                                });
                                _fetchAllHotels();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(117, 43, 161, 141),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 30,
                                color: Color.fromARGB(255, 62, 61, 61),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hotel.hotelName ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_box_outlined,
                    color: Colors.teal, size: 28),
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
              )
            ],
          ),
          if (hotel.hotelName2.isNotEmpty)
            Text(hotel.hotelName2, style: TextStyle(fontSize: 14)),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hotel.hotelPhoto,
                  width: 120,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ราคา : เริ่มต้น ${hotel.startingPrice} บาท'),
                    Text(hotel.location),
                    Text('โทรศัพท์ : ${hotel.phone}'),
                    if (hotel.contact.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Facebook : "),
                              TextSpan(
                                text: hotel.contact,
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              ),
                            ],
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
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(child: CircularProgressIndicator()),
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
