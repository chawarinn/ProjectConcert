import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev_log;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/DetailHotel.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'package:project_concert_closeiin/model/response/userGetSearchHResponse.dart';

class Hotelevent extends StatefulWidget {
  final int userId;
  final int eventID;
  final double eventLat;
  final double eventLng;

  const Hotelevent({
    super.key,
    required this.userId,
    required this.eventID,
    required this.eventLat,
    required this.eventLng,
  });

  @override
  _HoteleventState createState() => _HoteleventState();
}

class _HoteleventState extends State<Hotelevent> {
  int _currentIndex = 0;
  late String url;
  String _searchHotel = '';
  double? minPrice;
  double? maxPrice;
  bool _isLoading = false;

  List<UserHotelGetResponse> hotels = [];
  List<UserHotelGetResponse> filteredHotels = [];

  List<UserSearchHGetResponse> searchHotels = [];
  List<UserSearchHGetResponse> filteredSearchHotels = [];

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

  Future<void> _fetchAllHotels() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/hotelpiont'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        List<UserHotelGetResponse> loadedHotels =
            jsonData.map((e) => UserHotelGetResponse.fromJson(e)).toList();

        for (var hotel in loadedHotels) {
          if (hotel.lat != null && hotel.long != null) {
            hotel.distance = calculateDistance(
              widget.eventLat,
              widget.eventLng,
              hotel.lat!,
              hotel.long!,
            );
          } else {
            hotel.distance = double.infinity;
          }
        }

        loadedHotels.sort((a, b) {
          int distanceCompare = (a.distance ?? double.infinity)
              .compareTo(b.distance ?? double.infinity);
          if (distanceCompare != 0) {
            return distanceCompare;
          } else {
            return (b.totalPiont ?? 0).compareTo(a.totalPiont ?? 0);
          }
        });

        // ✅ ระยะทางไม่เกิน 30 กิโลเมตร
        loadedHotels = loadedHotels
            .where((hotel) => (hotel.distance ?? double.infinity) <= 30)
            .toList();

        setState(() {
          hotels = loadedHotels;
          filteredHotels = List.from(hotels);
        });

        setState(() {
          hotels = loadedHotels;
          filteredHotels = List.from(hotels);
        });
      } else {
        dev_log.log('Failed to fetch hotels: ${response.statusCode}');
      }
    } catch (e) {
      dev_log.log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _toRadians(double degree) => degree * pi / 180;

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _filterHotelList(String query) async {
    _searchHotel = query;
    if (query.isEmpty) {
      setState(() {
        filteredSearchHotels = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$API_ENDPOINT/search/hotel?query=$query'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        setState(() {
          searchHotels =
              jsonData.map((e) => UserSearchHGetResponse.fromJson(e)).toList();
          filteredSearchHotels = List.from(searchHotels);
        });
      } else {
        dev_log.log('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      dev_log.log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterHotelsByPrice() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (minPrice != null && maxPrice != null) {
        filteredHotels = hotels.where((hotel) {
          final price = double.tryParse(hotel.startingPrice.toString()) ?? 0.0;
          return price >= minPrice! && price <= maxPrice!;
        }).toList();

      // ✅ ระยะทางไม่เกิน 30 กิโลเมตร
        filteredHotels = filteredHotels
            .where((hotel) => (hotel.distance ?? double.infinity) <= 30)
            .toList();

        filteredHotels.sort((a, b) {
          final distA = a.distance ?? double.infinity;
          final distB = b.distance ?? double.infinity;
          final int distanceCompare = distA.compareTo(distB);
          if (distanceCompare != 0) {
            return distanceCompare; 
          } else {
            return (b.totalPiont ?? 0)
                .compareTo(a.totalPiont ?? 0); 
          }
        });
      } else {
        filteredHotels = List.from(hotels);
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget buildHotelCard(dynamic hotel) {
    double? hotelLat = double.tryParse(hotel.lat?.toString() ?? '');
    double? hotelLng = double.tryParse(hotel.long?.toString() ?? '');

    double? distance;
    if (hotelLat != null && hotelLng != null) {
      distance = calculateDistance(
          widget.eventLat, widget.eventLng, hotelLat, hotelLng);
    }

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailHotel(
              userId: widget.userId,
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hotel.hotelName ?? '',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text('${hotel.totalPiont ?? 0}/',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
              if ((hotel.hotelName2 ?? '').isNotEmpty)
                Text(hotel.hotelName2, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      hotel.hotelPhoto ?? '',
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ราคา : เริ่มต้น ${hotel.startingPrice} บาท'),
                        const SizedBox(height: 6),
                        Text(hotel.location ?? ''),
                        const SizedBox(height: 6),
                        Text('โทรศัพท์ : ${hotel.phone ?? ''}'),
                        if ((hotel.contact ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
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
                        if (distance != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                                'ระยะทาง : ${distance.toStringAsFixed(2)} กม.'),
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
    final List<dynamic> displayList =
        _searchHotel.isNotEmpty ? filteredSearchHotels : filteredHotels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
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
                      child: const Text('No',style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterHotelList,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                      items: [
                        _buildPriceFilter(
                            'ราคาเริ่มต้น 500 บาท', 500, double.infinity),
                        _buildPriceFilter('1,000 - 2,000 บาท', 1000, 2000),
                        _buildPriceFilter('2,000 - 3,000 บาท', 2000, 3000),
                        _buildPriceFilter(
                            'มากกว่า 3,000 บาท', 3000, double.infinity),
                        const PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(Icons.clear, size: 18, color: Colors.grey),
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
                    ).then((value) {
                      if (value == 'all') {
                        setState(() {
                          minPrice = null;
                          maxPrice = null;
                        });
                      } else if (value is List) {
                        minPrice = value[0];
                        maxPrice = value[1];
                      }
                      _filterHotelsByPrice();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? const Center(child: Text('No hotels found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayList.length,
                        itemBuilder: (_, i) => buildHotelCard(displayList[i]),
                      ),
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
                        Homemember(userId: widget.userId)), // 👈 ใส่หน้า Home
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ArtistPage(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NotificationPage(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileMember(
                          userId: widget.userId,
                        )),
              );
              break;
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

  PopupMenuItem _buildPriceFilter(String label, double min, double max) {
    return PopupMenuItem(
      value: [min, max],
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 18, color: Colors.purple.shade300),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
