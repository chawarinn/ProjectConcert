// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:project_concert_closeiin/Page/User/artistUser.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_concert_closeiin/Page/User/restaurantHotelUser.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class detailHoteluser extends StatefulWidget {
  final int hotelID;

  detailHoteluser({super.key,required this.hotelID});
  @override
  _detailHoteluserState createState() => _detailHoteluserState();
}

class _detailHoteluserState extends State<detailHoteluser> {
  int _currentIndex = 0;
  Map<String, dynamic>? hotel;
  bool isLoading = true;
  String url = '';
  List<String> firebaseImageUrls = [];
  List<Map<String, dynamic>> nearbyRestaurants = [];
  bool _hasRated = false;
  final DatabaseReference rating =
      FirebaseDatabase.instance.ref().child('point');

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });

    fetchHotel();
    fetchHotelPhotosFromFirebase();
  }

  Future<void> fetchHotelPhotosFromFirebase() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('photo')
          .where('hotelID', isEqualTo: widget.hotelID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          firebaseImageUrls =
              List<String>.from(querySnapshot.docs.first['photo']);
        });
      } else {
        log('No photos found for hotelID ${widget.hotelID}');
      }
    } catch (e) {
      log('Error fetching photos from Firebase: $e');
    }
  }

  Future<void> fetchHotel() async {
    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/hoteldetail?hotelID=${widget.hotelID}'),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (!mounted) return; // เช็คก่อน setState
        setState(() {
          hotel = decoded;
          isLoading = false;
        });
        fetchNearbyRestaurants();
      } else {
        throw Exception('Failed to load hotel');
      }
    } catch (e) {
      log('Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchNearbyRestaurants() async {
    try {
      final res = await http.get(Uri.parse('$API_ENDPOINT/Restaurant'));
      if (res.statusCode == 200 && hotel != null) {
        final List data = json.decode(res.body);

        final hotelLat = double.tryParse(hotel!['lat'].toString()) ?? 0.0;
        final hotelLng = double.tryParse(hotel!['long'].toString()) ?? 0.0;

        final restaurants = data.map<Map<String, dynamic>>((r) {
          final restLat = double.tryParse(r['lat'].toString()) ?? 0.0;
          final restLng = double.tryParse(r['long'].toString()) ?? 0.0;
          final distance =
              calculateDistance(hotelLat, hotelLng, restLat, restLng);
          return {
            ...r,
            'distance': distance,
          };
        }).toList();

        restaurants.sort((a, b) => a['distance'].compareTo(b['distance']));
        if (!mounted) return; // เช็คก่อน setState
        setState(() {
          nearbyRestaurants = restaurants.take(3).toList();
        });
      }
    } catch (e) {
      log('Error fetching restaurants: $e');
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  @override
  Widget build(BuildContext context) {
    final imageUrls = [
      if (hotel?['hotelPhoto'] != null &&
          hotel!['hotelPhoto'].toString().isNotEmpty)
        hotel!['hotelPhoto'],
      ...firebaseImageUrls
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Detail',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) {
                if (value == 'Login') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginPage()), 
                  );
                } else if (value == 'Sign Up') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RegisterPageUser()), 
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'Login',
                  child: Text('Log in', style: TextStyle(color: Colors.black)),
                ),
                const PopupMenuItem<String>(
                  value: 'Sign Up',
                  child: Text('Sign Up', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      body: isLoading || hotel == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotel!['hotelName'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _hasRated ? Icons.star : Icons.star_border,
                                color: _hasRated ? Colors.yellow : Colors.black,
                              ),
                              onPressed: () {
                                showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  titlePadding: EdgeInsets.only(
                      top: 16, left: 16, right: 8), // เพิ่ม padding สวยงาม
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notification',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        splashRadius: 20,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  content: Text('กรุณาเข้าสู่ระบบก่อน'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Log in', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPageUser()),
                        );
                      },
                      child: Text('Sign up', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              },
            );
                                }
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 16),
                    child: Text(
                      hotel!['hotelName2'],
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      controller: PageController(viewportFraction: 0.93),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            child: SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      color: Colors.grey[200],
                      padding:  const EdgeInsets.only(left: 10, top: 3),
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25,right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('ราคา : ',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('เริ่มต้น ', style: TextStyle(fontSize: 16)),
                            Text(hotel!['startingPrice'].toString(),
                                style: TextStyle(fontSize: 16)),
                            Text(' บาท', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('ประเภท : ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Column(
                          children:
                              (hotel?['rooms'] as List<dynamic>? ?? []).map(
                            (room) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade100),
                                  ),
                                  child: ListTile(
                                    leading: room['photo'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.network(
                                              room['photo'],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                );
                                              },
                                            ),
                                          )
                                        : null,
                                    title: Text(room['roomName'] ?? ''),
                                    subtitle:
                                        Text('ราคา : ${room['price']} บาท'),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        SizedBox(height: 16),
                        Text('สิ่งอำนวยความสะดวก : ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          hotel!['detail'],
                          style: TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                        SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'ที่อยู่ : ',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: hotel!['location'],
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          softWrap: true,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'รีวิว : ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                               hotel!['totalPiont'].toString(),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              ' คะแนน',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      color: Colors.grey[200],
                      padding:  const EdgeInsets.only(left: 10, top: 3),
                      child: Text(
                        'Map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 29, right: 29),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: hotel!['lat'] != null && hotel!['long'] != null
                            ? GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    double.tryParse(hotel!['lat'].toString()) ??
                                        0.0,
                                    double.tryParse(
                                            hotel!['long'].toString()) ??
                                        0.0,
                                  ),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId('event_location'),
                                    position: LatLng(
                                      double.tryParse(
                                              hotel!['lat'].toString()) ??
                                          0.0,
                                      double.tryParse(
                                              hotel!['long'].toString()) ??
                                          0.0,
                                    ),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                              )
                            : Center(child: Text('ไม่มีข้อมูลแผนที่')),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      color: Colors.grey[200],
                      padding:  const EdgeInsets.only(left: 10, top: 3),
                      child: Text(
                        'Nearby Restaurants',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 16),
                      child: Row(
                        children: [
                          ...nearbyRestaurants.map((r) => Container(
                                width: 400, // กำหนดความกว้างการ์ดเท่าเดิม
                                height: 160,
                                margin: EdgeInsets.only(right: 3),
                                child: Card(
                                  color: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: r['resPhoto'] != null
                                              ? Image.network(
                                                  r['resPhoto'],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey[400],
                                                  child: Icon(Icons.image,
                                                      color: Colors.white),
                                                ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(r['resName'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "ประเภทอาหาร : ",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: r['type'] ?? '',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "ที่อยู่ : ",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: r['location'] ?? '',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (r['distance'] != null)
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "ระยะทาง : ",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      TextSpan(
                                                        text: r['distance']
                                                            .toStringAsFixed(2),
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      TextSpan(
                                                        text: " กม.",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "ติดต่อ : ",
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                      text: r['contact'] ??
                                                          'No Contact',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            r['contact'] == null
                                                                ? Colors.red
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          Container(
                            margin: EdgeInsets.only(right: 12),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                   Colors.grey[200],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RestaurantHotelUser(
                                          hotelID: widget.hotelID,
                                          hotelLat: hotel!['lat'],
                                          hotelLng: hotel!['long'])),
                                );
                                if (result == true) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  fetchHotel();
                                  fetchHotelPhotosFromFirebase();
                                }
                              },
                              child: Text("More",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2 || index == 3) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  titlePadding: EdgeInsets.only(
                      top: 16, left: 16, right: 8), // เพิ่ม padding สวยงาม
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notification',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        splashRadius: 20,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  content: Text('กรุณาเข้าสู่ระบบก่อน'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Log in', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPageUser()),
                        );
                      },
                      child: Text('Sign up', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              },
            );
          } else {
            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeUser()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ArtistUserPage()),
                );
                break;
            }
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
              icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: ''),
        ],
      ),
    );
  }
}
