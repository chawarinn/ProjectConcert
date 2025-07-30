// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:project_concert_closeiin/Page/User/artistUser.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

class Restaurantuser extends StatefulWidget {
  @override
  _RestaurantuserState createState() => _RestaurantuserState();
}

class _RestaurantuserState extends State<Restaurantuser> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> restaurants = [];
  String query = "";
  String url = '';
  String? selectedVenue;
  int _currentIndex = 0;
  bool isLoading = false;

  final Map<String, LatLng> concertVenues = {
    'Impact Arena': LatLng(13.988, 100.522),
    'Thunder Dome': LatLng(13.945, 100.595),
    'Rajamangala National Stadium': LatLng(13.7556, 100.6212),
  };

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (config) {
        url = config['apiEndpoint'];
      },
    ).catchError((err) {});
    fetchRestaurants(); // โหลดทั้งหมดเริ่มต้น
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> fetchRestaurants() async {
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse('$API_ENDPOINT/search/restaurant?query=$query');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (selectedVenue != null) {
          LatLng venueLatLng = concertVenues[selectedVenue]!;

          for (var res in data) {
            double resLat = double.tryParse(res['lat'].toString()) ?? 0;
            double resLon = double.tryParse(res['long'].toString()) ?? 0;
            res['distance'] = calculateDistance(
              venueLatLng.latitude,
              venueLatLng.longitude,
              resLat,
              resLon,
            );
          }

          data.sort((a, b) => a['distance'].compareTo(b['distance']));
        }

        setState(() {
          restaurants = data;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildRestaurantCard(dynamic res) {
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
                       }
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
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
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
                          text: "ที่อยู่ : ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "ติดต่อ : ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        //รอลองเครื่องจริง
                        double lat =
                            double.tryParse(res['lat'].toString()) ?? 0;
                        double lng =
                            double.tryParse(res['long'].toString()) ?? 0;
                        final Uri uri = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$lat,$lng');

                        try {
                          bool launched = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched) {
                            print('Could not launch map');
                          }
                        } catch (e) {
                          print('Exception launching map: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 4),
                      ),
                      child: Text(
                        'Map',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Restaurant',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
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
                  child: Text('Sign Up',  style: TextStyle(color: Colors.black)),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 200,
                    height: 40,
                    margin: const EdgeInsets.only(right: 10),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          query = val;
                        });
                        fetchRestaurants();
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
                  Wrap(
                    spacing: 8,
                    children: concertVenues.entries.map((entry) {
                      final bool isSelected = selectedVenue == entry.key;
                      return FilterChip(
                        label: Text(
                          entry.key,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Color.fromRGBO(201, 151, 187, 1),
                        backgroundColor: Colors.grey[200],
                        checkmarkColor: Colors.white,
                        side: BorderSide.none, 
                        onSelected: (selected) {
                          setState(() {
                            selectedVenue = selected ? entry.key : null;
                          });
                          fetchRestaurants();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            )
          else if (restaurants.isEmpty)
            Expanded(
              child: Center(
                child: Text('No restaurants found'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return buildRestaurantCard(restaurants[index]);
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
                      child: Text('Log in',  style: TextStyle(color: Colors.black)),
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
                      child: Text('Sign up',  style: TextStyle(color: Colors.black)),
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
