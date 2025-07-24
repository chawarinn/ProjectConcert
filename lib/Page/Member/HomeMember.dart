// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/DetailHotel.dart';
import 'package:project_concert_closeiin/Page/Member/Event.dart';
import 'package:project_concert_closeiin/Page/Member/EventDetailMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/Restaurant_search.dart';
import 'package:project_concert_closeiin/Page/Member/RoomShare.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/Page/Member/hotel_search.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class Homemember extends StatefulWidget {
  int userId;
  Homemember({super.key, required this.userId});
  @override
  _HomeMember createState() => _HomeMember();
}

class _HomeMember extends State<Homemember> {
  int _currentIndex = 0;
  String url = '';
  List<dynamic> eventList = [];
  bool isLoading = true;
  List<dynamic> topHotels = [];

  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
    fetchEvent();
    fetchTopHotels();
  }

  Future<void> fetchEvent() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/Event'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          eventList = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTopHotels() async {
    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/hotelpiont'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          topHotels = decoded.take(5).toList();
        });
      } else {
        throw Exception('Failed to load top hotels');
      }
    } catch (e) {
      print('Error fetching hotels: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Concert Close Inn',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildIconWithLabel(
                                    FontAwesomeIcons.ticket,
                                    "Event",
                                    () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Event(userId: widget.userId),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                        fetchTopHotels();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _buildIconWithLabel(
                                    FontAwesomeIcons.hotel,
                                    "Hotel",
                                         () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HotelSearch(
                                              userId: widget.userId),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                        fetchTopHotels();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _buildIconWithLabel(
                                    FontAwesomeIcons.bed,
                                    "Room Share",
                                     () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Roomshare(userId: widget.userId),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                        fetchTopHotels();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _buildIconWithLabel(
                                    FontAwesomeIcons.utensils,
                                    "Restaurant",
                                    () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RestaurantSearch(
                                                  userId: widget.userId),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                        fetchTopHotels();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Event Section
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Event',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];

                        final leftMargin = index == 0 ? 16.0 : 0.0;

                        return Container(
                          margin: EdgeInsets.only(left: leftMargin, right: 8),
                          child: GestureDetector(
                            onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                  builder: (context) => Eventdetailmember(
                                    userId: widget.userId,
                                    eventID: event['eventID'],
                                  ),
                                ),
                              );
                                      if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                        fetchTopHotels();
                                      }
                            },
                            child: _buildEventCardWidget(
                              Image.network(
                                event['eventPhoto'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Top 5 Hotel',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: topHotels.length,
                      itemBuilder: (context, index) {
                        final hotel = topHotels[index];
                        return _buildHotelCard(hotel);
                      },
                    ),
                  ),
                ],
              ),
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
                    builder: (context) => Homemember(userId: widget.userId)),
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

  Widget _buildIconWithLabel(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: const Color.fromARGB(199, 0, 0, 0)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEventCardWidget(Widget imageWidget) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 150,
          color: Colors.grey.shade300,
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildHotelCard(dynamic hotel) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailHotel(
              userId: widget.userId,
              hotelID: hotel['hotelID'],
            ),
          ),
        );
        if (result == true) {
          setState(() {
            isLoading = false;
          });
         fetchEvent();
    fetchTopHotels();
        }
      },
      child:  Card(
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
                      hotel['hotelName'] ?? '',
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
                          '${hotel['totalPiont'] ?? 0}/',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              Text(hotel['hotelName2'], style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      hotel['hotelPhoto'],
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
                        Text('ราคา : เริ่มต้น ${hotel['startingPrice']} บาท'),
                        SizedBox(height: 6),
                        Text(hotel['location']),
                        SizedBox(height: 6),
                        Text('โทรศัพท์ : ${hotel['phone']}'),
                        if (hotel['contact'].isNotEmpty) ...[
                          SizedBox(height: 6),
                         Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Facebook : ",
                                ),
                                TextSpan(
                                  text: hotel['contact'],
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
