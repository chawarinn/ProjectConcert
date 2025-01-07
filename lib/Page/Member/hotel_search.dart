
import 'dart:core';

import 'dart:math';
import 'dart:developer' as dev_log;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'package:project_concert_closeiin/model/response/userGetSearchHResponse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelSearch extends StatefulWidget {
  @override
  _hotelSearch createState() => _hotelSearch();
}

class _hotelSearch extends State<HotelSearch> {
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
    'Rajamangala National Stadium': LatLng(13.746, 100.560),
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
    try {
      var response = await http.get(Uri.parse('$API_ENDPOINT/hotel'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          hotels =
              jsonData.map((e) => UserHotelGetResponse.fromJson(e)).toList();
          filteredhotels = hotels;
        });
      } else {
        dev_log.log('Failed to fetch hotels: ${response.statusCode}');
        setState(() {
          hotels = [];
          filteredhotels = [];
        });
      }
    } catch (e) {
      dev_log.log(e.toString());
      setState(() {
        hotels = [];
        filteredhotels = [];
      });
    }
  }

  void _filterHotelList(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredhotels = hotels;
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
          });
        } else {
          dev_log.log('Failed to fetch hotels: ${response.statusCode}');
          setState(() {
            filteredhotel = [];
          });
        }
      } catch (e) {
        dev_log.log(e.toString());
        setState(() {
          filteredhotel = [];
        });
      }
    }
  }

  void _filterHotelsByPrice() {
    if (minPrice != null && maxPrice != null) {
      setState(() {
        filteredhotels = hotels.where((hotel) {
          double price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
          return price >= minPrice! && price <= maxPrice!;
        }).toList();
        filteredhotel = hotel.where((hotel) {
          double price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
          return price >= minPrice! && price <= maxPrice!;
        }).toList();
      });
    } else {
      filteredhotels = List.from(hotels);
      filteredhotel = List.from(hotel);
    }
  }

  void _filterHotelsByLocation(String location) {
    LatLng selectedLocation = locations[location]!;

    setState(() {
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
          'hotel': hotel, // 
          'distance': distance, // เก็บระยะทาง
        };
      }).toList();

      hotelsWithDistance = hotelsWithDistance.where((item) {
        double distance = item['distance'] as double? ?? double.infinity;
        return distance <= 20.0; // ไม่เกิน 20 กิโลเมตร
      }).toList();

      // เรียงลำดับตามระยะทางจากน้อยไปมาก
      hotelsWithDistance.sort((a, b) {
        double distanceA = a['distance'] as double? ?? double.infinity;
        double distanceB = b['distance'] as double? ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      filteredhotels = hotelsWithDistance
          .map((item) => item['hotel'] as UserHotelGetResponse)
          .toList();
    });
  }

  void _clearSelection() {
    setState(() {
      selectedButton = ''; // รีเซ็ตปุ่มที่เลือก
      distance = null; 
      showClearIcon = false; // ซ่อนกากบาท
      var hotelsWithDistance = hotels.map((hotel) {
        hotel.distance = null;
        return {
          'hotel': hotel, 
          'distance': distance, 
        };
      }).toList();
      filteredhotels = hotelsWithDistance
          .map((item) => item['hotel'] as UserHotelGetResponse)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Hotel',
          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Color.fromARGB(255, 190, 150, 198),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple.shade200,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
          } else if (index == 1) {
          } else if (index == 2) {
          } else if (index == 3) {}
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heartPulse),
              label: 'Favorite Artist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      onChanged: (value) {
                        _searchHotel = value;
                        _filterHotelList(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 216, 213, 213),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(100.0, 100.0, 0.0, 0.0),
                        items: [
                          PopupMenuItem(
                            child: Text('ราคาเริ่มต้น 500 บาท'),
                            value: 'filter1',
                          ),
                          PopupMenuItem(
                            child: Text('1,000 - 2,000 บาท'),
                            value: 'filter2',
                          ),
                          PopupMenuItem(
                            child: Text('2,000 - 3,000 บาท'),
                            value: 'filter3',
                          ),
                          PopupMenuItem(
                            child: Text('มากกว่า 3,000 บาท'),
                            value: 'filter4',
                          ),
                          PopupMenuItem(
                            child: Text('ทั้งหมด'),
                            value: 'filter5',
                          ),
                        ],
                        elevation: 8.0,
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
                  ElevatedButton(
                    onPressed: () {
                      _filterHotelsByLocation('Impact Arena');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedButton == 'Impact Arena'
                          ? Color.fromARGB(255, 190, 150, 198)
                          : Colors.grey.shade300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3, vertical: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Impact Arena',
                          style: TextStyle(
                            color: selectedButton == 'Impact Arena'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedButton == 'Impact Arena')
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: _clearSelection,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _filterHotelsByLocation('Thunder Dome');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedButton == 'Thunder Dome'
                          ? Color.fromARGB(255, 190, 150, 198)
                          : Colors.grey.shade300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3, vertical: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Thunder Dome',
                          style: TextStyle(
                            color: selectedButton == 'Thunder Dome'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedButton == 'Thunder Dome')
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: _clearSelection,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _filterHotelsByLocation('Rajamangala National Stadium');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedButton == 'Rajamangala National Stadium'
                              ? Color.fromARGB(255, 190, 150, 198)
                              : Colors.grey.shade300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3, vertical: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Rajamangala National Stadium',
                          style: TextStyle(
                            color:
                                selectedButton == 'Rajamangala National Stadium'
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedButton ==
                            'Rajamangala National Stadium') 
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.red),
                            onPressed: _clearSelection,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredhotels.isEmpty
                  ? Center(
                      child: Text(
                        'ไม่มีโรงแรมที่ต้องการ',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        if (filteredhotel.isEmpty || _searchHotel.isEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredhotels.length,
                              itemBuilder: (context, index) {
                                var hotels = filteredhotels[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            child: Image.network(
                                              hotels.hotelPhoto,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hotels.hotelName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                hotels.hotelName2,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'ราคา : เริ่มต้น ${hotels.startingPrice} บาท',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                hotels.location,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                'โทรศัพท์ : ${hotels.phone}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                'Facebook : ${hotels.contact}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                              if (hotels.distance != null &&
                                                  hotels.distance! > 0)
                                                Text(
                                                  'ระยะห่าง : ${hotels.distance!.toStringAsFixed(2)} กม.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (filteredhotel.isNotEmpty && _searchHotel.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredhotel.length,
                              itemBuilder: (context, index) {
                                var hotel = filteredhotel[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            child: Image.network(
                                              hotel.hotelPhoto,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hotel.hotelName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (hotel.hotelName2 != null &&
                                                  hotel.hotelName2.isNotEmpty)
                                                Text(
                                                  hotel.hotelName2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'ราคา : เริ่มต้น ${hotel.startingPrice} บาท',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                hotel.location,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              Text(
                                                'โทรศัพท์ : ${hotel.phone}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              if (hotel.contact != null &&
                                                  hotel.contact.isNotEmpty)
                                                Text(
                                                  'Facebook : ${hotel.contact}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              if (hotel.distance != null &&
                                                  hotel.distance! > 0)
                                                Text(
                                                  'ระยะห่าง : ${hotel.distance} กม.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
