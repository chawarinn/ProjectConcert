// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/ResHotel.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:io';


class DetailHotel extends StatefulWidget {
  final int userId;
  final int hotelID;

  DetailHotel({super.key, required this.userId, required this.hotelID});

  @override
  _DetailHotelState createState() => _DetailHotelState();
}

class _DetailHotelState extends State<DetailHotel> {
  int _currentIndex = 0;
  int _rating = 0;
  Map<String, dynamic>? hotel;
  bool isLoading = true;
  String url = '';
  List<String> firebaseImageUrls = [];
  List<Map<String, dynamic>> nearbyRestaurants = [];
  bool _hasRated = false;
  final DatabaseReference rating =
      FirebaseDatabase.instance.ref().child('point');
  int? totalPoint;
  StreamSubscription<DatabaseEvent>? _pointSubscription;

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
    checkIfRated();
    listenToTotalPoint();
  }
  @override
void dispose() {
  _pointSubscription?.cancel(); // ยกเลิก listener เมื่อ widget ถูก dispose
  super.dispose();
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
       throw Exception('ไม่สามารถโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง');
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
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkIfRated() async {
    try {
      final response = await http.get(Uri.parse(
          '$API_ENDPOINT/checkpoint?userID=${widget.userId}&hotelID=${widget.hotelID}'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _hasRated = result['hasRated'];
          _rating = _hasRated ? 1 : 0;
        });
      } else {
        print('Check rating failed');
      }
    } catch (e) {
      print('Error checking rating: $e');
    }
  }

void listenToTotalPoint() {
  final ref = FirebaseDatabase.instance.ref('/point/ratings');

  _pointSubscription = ref.onValue.listen((event) {
    final data = event.snapshot.value;
    int sum = 0;

    if (data is Map) {
      data.forEach((userId, userRatings) {
        if (userRatings is Map) {
          final hotelData = userRatings[widget.hotelID.toString()];
          if (hotelData is Map && hotelData['rating'] != null) {
            final rating = int.tryParse(hotelData['rating'].toString()) ?? 0;
            sum += rating;
          }
        }
      });
    }

    setState(() {
      totalPoint = sum;
    });
  });
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
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Detail',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
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
      body: isLoading || hotel == null
          ? Center(child: CircularProgressIndicator(color: Colors.black))
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
                              onPressed: () async {
                                if (_hasRated) {
                                  // ลบคะแนน
                                  setState(() {
                                    _hasRated = false;
                                    _rating = 0;
                                  });

                                  final response = await http.delete(
                                    Uri.parse(
                                        '$API_ENDPOINT/deletepoint?userID=${widget.userId}&hotelID=${widget.hotelID}'),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      'userID': widget.userId,
                                      'hotelID': widget.hotelID,
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    print('ลบคะแนนเรียบร้อย');

                                    // ลบจาก Firebase Realtime
                                    await rating
                                        .child("ratings")
                                        .child(widget.userId.toString())
                                        .child(widget.hotelID.toString())
                                        .remove();
                                  } else {
                                    print('ลบคะแนนไม่สำเร็จ');
                                    setState(() {
                                      _hasRated = true;
                                      _rating = 1;
                                    });
                                  }
                                } else {
                                  // ให้คะแนน
                                  setState(() {
                                    _hasRated = true;
                                    _rating = 1;
                                  });

                                  final response = await http.post(
                                    Uri.parse('$API_ENDPOINT/addpoint'),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      'userID': widget.userId,
                                      'hotelID': widget.hotelID,
                                    }),
                                  );

                                  if (response.statusCode == 201) {
                                    print('บันทึกคะแนนเรียบร้อย');

                                    // เพิ่มลง Firebase Realtime
                                    await rating
                                        .child("ratings")
                                        .child(widget.userId.toString())
                                        .child(widget.hotelID.toString())
                                        .set({
                                      "rated": true,
                                      "rating": 1,
                                      "timestamp":
                                          DateTime.now().toIso8601String(),
                                    });
                                  } else {
                                    print('บันทึกคะแนนไม่สำเร็จ');
                                    setState(() {
                                      _hasRated = false;
                                      _rating = 0;
                                    });
                                  }
                                }
                              },
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
  children: (hotel?['rooms'] as List<dynamic>? ?? []).map(
    (room) {
      final status = room['status'];
      final statusText = status == 1 ? 'เต็ม' : 'ว่าง';
      final statusColor = status == 1 ? Colors.red : Colors.green;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            leading: room['photo'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      room['photo'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, color: Colors.grey);
                      },
                    ),
                  )
                : null,
            title: Text(room['roomName'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ราคา : ${room['price']} บาท'),
                Text(
                  '$statusText',
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
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
                                text: 'ที่ตั้ง : ',
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
                              (totalPoint?.toString() ?? '0'),
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
                                width: 400, 
                                height: 175,
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
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                     errorBuilder: (context, error, stackTrace) {
            return Container(
                      width: 100,
                      height: 120,
                      color: Colors.grey[400],
                      child: Icon(Icons.image, color: Colors.white),
                    );
                       }
                                                )
                                              : Container(
                                                  width: 100,
                                                  height: 120,
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
                          text: "เวลา : ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: r['open'] ?? '',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " - ",
                          style: TextStyle(
                              fontSize: 12),
                        ),
                        TextSpan(
                          text: r['close'] ?? '',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " น. ",
                          style: TextStyle(
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "ที่ตั้ง : ",
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
                                      builder: (context) => RestaurantHotel(
                                          userId: widget.userId,
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
                                  checkIfRated();
                                  listenToTotalPoint();
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
        onTap: (index) async {
  final box = GetStorage();
  switch (index) {
    case 0:
      await box.write('lastVisitedPage', 'home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homemember(userId: widget.userId)),
      );
      break;
    case 1:
      await box.write('lastVisitedPage', 'artist');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArtistPage(userId: widget.userId)),
      );
      break;
    case 2:
      await box.write('lastVisitedPage', 'notification');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotificationPage(userId: widget.userId)),
      );
      break;
    case 3:
      await box.write('lastVisitedPage', 'profile');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileMember(userId: widget.userId)),
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
              icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: ''),
        ],
      ),
    );
  }
}
