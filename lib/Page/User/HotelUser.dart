// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:project_concert_closeiin/Page/User/artistUser.dart';
import 'dart:core';
import 'dart:math';
import 'dart:developer' as dev_log;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/User/detailHotelUser.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'package:project_concert_closeiin/model/response/userGetSearchHResponse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Hoteluser extends StatefulWidget {
  @override
  _HoteluserState createState() => _HoteluserState();
}

class _HoteluserState extends State<Hoteluser> {
  int _currentIndex = 0;
  List<UserSearchHGetResponse> hotel = [];
  List<UserSearchHGetResponse> filteredhotel = [];
  List<UserHotelGetResponse> hotels = [];
  List<UserHotelGetResponse> filteredhotels = [];
  String url = '';
  String _searchHotel = '';
  String selectedValue = '';
  double? minPrice;
  double? maxPrice;
  double? distance;
  String selectedLocation = '';
  bool showClearIcon = false;
  String selectedButton = '';
  int? selectedPrice;
  bool _isLoading = false;

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;

    double lat1Rad = lat1 * pi / 180;
    double lon1Rad = lon1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double lon2Rad = lon2 * pi / 180;

    double dlat = lat2Rad - lat1Rad;
    double dlon = lon2Rad - lon1Rad;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  Map<String, LatLng> locations = {
    'Impact Arena': LatLng(13.988, 100.522),
    'Thunder Dome': LatLng(13.945, 100.595),
    'Rajamangala National Stadium': LatLng(13.7556, 100.6212),
  };

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      dev_log.log(err.toString());
    });
    _fetchAllHotels();
  }

  void _fetchAllHotels() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.get(Uri.parse('$API_ENDPOINT/hotelpiont'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          hotels =
              jsonData.map((e) => UserHotelGetResponse.fromJson(e)).toList();
          filteredhotels = hotels;
          _isLoading = false;
        });
      } else {
        dev_log.log('Failed to fetch hotels: ${response.statusCode}');
        setState(() {
          hotels = [];
          filteredhotels = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      dev_log.log(e.toString());
      setState(() {
        hotels = [];
        filteredhotels = [];
        _isLoading = false;
      });
    }
  }

  void _filterHotelList(String query) async {
    _searchHotel = query;
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        filteredhotel = [];
        _isLoading = false;
      });
    } else {
      try {
        var response = await http
            .get(Uri.parse('$API_ENDPOINT/search/hotel?query=$query'));
        if (response.statusCode == 200) {
          List<dynamic> jsonData = json.decode(response.body);
          setState(() {
            filteredhotel = jsonData
                .map((e) => UserSearchHGetResponse.fromJson(e))
                .toList();
            _isLoading = false;
          });
        } else {
          dev_log.log('Failed to fetch hotels: ${response.statusCode}');
          setState(() {
            filteredhotel = [];
            _isLoading = false;
          });
        }
      } catch (e) {
        dev_log.log(e.toString());
        setState(() {
          filteredhotel = [];
          _isLoading = false;
        });
      }
    }
  }

  void _filterHotelsByPrice() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 300));

    if (minPrice != null && maxPrice != null) {
      List<UserHotelGetResponse> targetList;

      if (selectedButton.isNotEmpty) {
        // ถ้ามีการเลือกสถานที่ไว้ -> กรองจาก filteredhotels เดิมที่มีระยะทางแล้ว
        targetList = filteredhotels;
      } else {
        // ถ้ายังไม่ได้เลือกสถานที่ -> ใช้ทั้งหมด
        targetList = hotels;
      }

      filteredhotels = targetList.where((hotel) {
        double price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
        return price >= minPrice! && price <= maxPrice!;
      }).toList();

      filteredhotel = hotel.where((hotel) {
        double price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
        return price >= minPrice! && price <= maxPrice!;
      }).toList();

      filteredhotels.sort((a, b) {
        double priceA = double.tryParse(a.startingPrice.toString()) ?? 0.0;
        double priceB = double.tryParse(b.startingPrice.toString()) ?? 0.0;
        return priceA.compareTo(priceB);
      });

      filteredhotel.sort((a, b) {
        double priceA = double.tryParse(a.startingPrice.toString()) ?? 0.0;
        double priceB = double.tryParse(b.startingPrice.toString()) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else {
      if (selectedButton.isNotEmpty) {
        // ถ้าเคยเลือก location ไว้ และล้างราคากรองออก → แสดงรายการโรงแรมตามระยะทางเดิม
        _filterHotelsByLocation(selectedButton);
        return;
      } else {
        filteredhotels = List.from(hotels);
        filteredhotel = List.from(hotel);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterHotelsByLocation(String location) async {
    setState(() {
      _isLoading = true; // เริ่มแสดง loading
    });

    LatLng selectedLocation = locations[location]!;

    // เพิ่ม delay เล็กน้อย (ถ้าไม่ต้องการลบได้)
    await Future.delayed(Duration(milliseconds: 300));

    var hotelsWithDistance = hotels.map((hotel) {
      selectedButton = location;
      showClearIcon = true;

      double hotelLat = hotel.lat;
      double hotelLon = hotel.long;

      double distance = _calculateDistance(
        selectedLocation.latitude,
        selectedLocation.longitude,
        hotelLat,
        hotelLon,
      );

      hotel.distance = distance;

      return {
        'hotel': hotel,
        'distance': distance,
      };
    }).toList();

    // กรองราคาถ้ามีการตั้ง minPrice
    if (minPrice != null) {
      hotelsWithDistance = hotelsWithDistance.where((item) {
        final hotel = item['hotel'] as UserHotelGetResponse;
        final price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
        return price >= minPrice!;
      }).toList();
    }

    // hotelsWithDistance = hotelsWithDistance.where((item) {
    //   double distance = item['distance'] as double? ?? double.infinity;
    //   return distance <= 20.0; // ไม่เกิน 20 กิโลเมตร
    // }).toList();

    // เรียงลำดับตามระยะทางจากน้อยไปมาก
    hotelsWithDistance.sort((a, b) {
      double distanceA = a['distance'] as double? ?? double.infinity;
      double distanceB = b['distance'] as double? ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      filteredhotels = hotelsWithDistance
          .map((item) => item['hotel'] as UserHotelGetResponse)
          .toList();

      _isLoading = false; // โหลดเสร็จซ่อน loading
    });
  }

  void _clearSelection() async {
    setState(() {
      _isLoading = true; // เริ่มโหลด
    });

    await Future.delayed(Duration(milliseconds: 300)); // ให้มี delay เล็กน้อย

    var hotelsWithDistance = hotels.map((hotel) {
      hotel.distance = null;
      return {
        'hotel': hotel,
        'distance': null,
      };
    }).toList();

    if (minPrice != null) {
      hotelsWithDistance = hotelsWithDistance.where((item) {
        final hotel = item['hotel'] as UserHotelGetResponse;
        final price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
        return price >= minPrice!;
      }).toList();
    }

    hotelsWithDistance.sort((a, b) {
      final hotelA = a['hotel'] as UserHotelGetResponse;
      final hotelB = b['hotel'] as UserHotelGetResponse;
      double priceA = double.tryParse(hotelA.startingPrice.toString()) ?? 0.0;
      double priceB = double.tryParse(hotelB.startingPrice.toString()) ?? 0.0;
      return priceA.compareTo(priceB);
    });

    setState(() {
      selectedButton = '';
      distance = null;
      showClearIcon = false;

      filteredhotels = hotelsWithDistance
          .map((item) => item['hotel'] as UserHotelGetResponse)
          .toList();

      _isLoading = false; // โหลดเสร็จ
    });
  }

  Widget buildHotelCard(var hotel) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detailHoteluser(
              hotelID: hotel.hotelId,
            ),
          ),
        );
        if (result == true) {
          setState(() {
            _isLoading = false;
          });
          _fetchAllHotels();
        }
      },
      child: Card(
        color: Colors.grey[200],
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hotel.hotelName ?? '',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${hotel.totalPiont ?? 0}/',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                  ),
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
                        SizedBox(height: 6),
                        Text(hotel.location),
                        SizedBox(height: 6),
                        Text('โทรศัพท์ : ${hotel.phone}'),
                        if (hotel.contact.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Facebook : ",
                                ),
                                TextSpan(
                                  text: hotel.contact,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (hotel.distance != null && hotel.distance! > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'ระยะห่าง : ${hotel.distance!.toStringAsFixed(2)} กม.',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text(
          'Hotel',
          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
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
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 200,
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        _searchHotel = value;
                        _filterHotelList(value);
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  IconButton(
                    icon: Icon(Icons.tune),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(100.0, 100.0, 0.0, 0.0),
                        items: [
                          PopupMenuItem(
                            value: 'filter1',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 18, color: Colors.purple.shade300),
                                SizedBox(width: 8),
                                Text(
                                  'ราคาเริ่มต้น 500 บาท',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'filter2',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 18, color: Colors.purple.shade300),
                                SizedBox(width: 8),
                                Text(
                                  '1,000 - 2,000 บาท',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'filter3',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 18, color: Colors.purple.shade300),
                                SizedBox(width: 8),
                                Text(
                                  '2,000 - 3,000 บาท',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'filter4',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money,
                                    size: 18, color: Colors.purple.shade300),
                                SizedBox(width: 8),
                                Text(
                                  'มากกว่า 3,000 บาท',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'filter5',
                            child: Row(
                              children: [
                                Icon(Icons.clear,
                                    size: 18, color: Colors.grey.shade400),
                                SizedBox(width: 8),
                                Text(
                                  'ทั้งหมด',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                        elevation: 4,
                      ).then((selectedValue) {
                        // จัดการค่าที่เลือกจากเมนู
                        if (selectedValue != null) {
                          switch (selectedValue) {
                            case 'filter1':
                              setState(() {
                                minPrice = 500;
                                maxPrice = double.infinity;
                              });
                              break;
                            case 'filter2':
                              setState(() {
                                minPrice = 1000;
                                maxPrice = 2000;
                              });
                              break;
                            case 'filter3':
                              setState(() {
                                minPrice = 2000;
                                maxPrice = 3000;
                              });
                              break;
                            case 'filter4':
                              setState(() {
                                minPrice = 3000;
                                maxPrice = double.infinity;
                              });
                              break;
                            case 'filter5':
                              setState(() {
                                minPrice = null;
                                maxPrice = null;
                                distance = null;
                              });
                              break;
                          }
                          _filterHotelsByPrice();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Wrap(
                    spacing: 8,
                    children: locations.entries.map((entry) {
                      final bool isSelected = selectedButton == entry.key;
                      return FilterChip(
                        label: Text(
                          entry.key,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color.fromRGBO(201, 151, 187, 1),
                        backgroundColor: Colors.grey[200],
                        checkmarkColor: Colors.white,
                        side: BorderSide.none,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filterHotelsByLocation(entry.key);
                            } else {
                              _clearSelection();
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : Builder(
                    builder: (context) {
                      if (_searchHotel.isNotEmpty) {
                        if (filteredhotel.isEmpty) {
                          return Center(
                            child: Text(
                              'No hotels found',
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: filteredhotel.length,
                            itemBuilder: (context, index) {
                              var hotel = filteredhotel[index];
                              return buildHotelCard(hotel);
                            },
                          );
                        }
                      } else {
                        if (filteredhotels.isEmpty) {
                          return Center(
                            child: Text(
                              'No hotels found',
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: ListView.builder(
                              itemCount: filteredhotels.length,
                              itemBuilder: (context, index) {
                                var hotel = filteredhotels[index];
                                return buildHotelCard(hotel);
                              },
                            ),
                          );
                        }
                      }
                    },
                  ),
          ),
        ],
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
                      top: 16, left: 16, right: 8),
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
        // showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heartPulse),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: '',
          ),
        ],
      ),
    );
  }
}
