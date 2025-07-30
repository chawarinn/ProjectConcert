// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/Member/TicketWebviewPage.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:project_concert_closeiin/Page/User/HotelEventUser.dart';
import 'package:project_concert_closeiin/Page/User/artistUser.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class EventdetailUser extends StatefulWidget {
  final int eventID;

  EventdetailUser({super.key,required this.eventID});

  @override
  _EventDetailUserState createState() => _EventDetailUserState();
}

class _EventDetailUserState extends State<EventdetailUser> {
  int _currentIndex = 0;
  Map<String, dynamic>? event;
  bool isLoading = true;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });
    fetchEvent();
  }

  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse('$API_ENDPOINT/detailevent?eventID=${widget.eventID}'),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          event = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load event');
      }
    } catch (e) {
      log('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchTicketUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }

  String formatDateThai(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const thaiMonths = [
        '',
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม'
      ];
      return '${dt.day} ${thaiMonths[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    } catch (_) {
      return timeStr;
    }
  }

  String formatLTime(String ltimeStr) {
    if (ltimeStr.isEmpty) return '';
    try {
      final parts = ltimeStr.split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')} น.';
    } catch (_) {
      return ltimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : event == null
              ? Center(child: Text('No events found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: event!['eventPhoto'] != null &&
                                  event!['eventPhoto'].isNotEmpty
                              ? Image.network(
                                  event!['eventPhoto'],
                                  height: 450,
                                  width: 350,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 300,
                                  width: double.infinity,
                                  color: Colors.grey,
                                  child: Center(child: Text('No image')),
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        event!['eventName'] ?? '',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size(100, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          event!['typeEventName'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${formatDateThai(event!['date'] ?? '')}\n'
                          '${formatTime(event!['time'] ?? '')} - '
                          '${formatLTime(event!['ltime'] ?? '')}\n'
                          '${event!['location'] ?? ''}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Artists',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...?event!['artists']?.map<Widget>((artist) =>
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            artist['artistPhoto'] != null &&
                                                    artist['artistPhoto']
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    artist['artistPhoto'])
                                                : null,
                                        child: (artist['artistPhoto'] == null ||
                                                artist['artistPhoto'].isEmpty)
                                            ? Icon(Icons.person, size: 40)
                                            : null,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        artist['artistName'] ?? '',
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                                                  ElevatedButton(
  style: TextButton.styleFrom(
    backgroundColor: Color.fromRGBO(201, 151, 187, 1),
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    minimumSize: Size(100, 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  onPressed: () {
    if (event!['linkticket'] != null &&
        event!['linkticket'].toString().startsWith('http')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TicketWebviewPage(url: event!['linkticket']),
        ),
      );
    }
  },
  child: Text(
    'Ticket',
    style: TextStyle(color: const Color.fromARGB(206, 0, 0, 0)),
  ),
),

                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                                    minimumSize: Size(100, 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                  builder: (_) => Hoteleventuser(
                                    eventID: widget.eventID,
                                    eventLat: event!['lat'],
                                    eventLng: event!['long'],
                                  ),
                                ),
                              );
                                if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
                                      }
                            },
                            child: Text('Hotel',
                                style: TextStyle(color: const Color.fromARGB(206, 0, 0, 0))),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Map',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: event!['lat'] != null && event!['long'] != null
                              ? GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      double.tryParse(
                                              event!['lat'].toString()) ??
                                          0.0,
                                      double.tryParse(
                                              event!['long'].toString()) ??
                                          0.0,
                                    ),
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId('event_location'),
                                      position: LatLng(
                                        double.tryParse(
                                                event!['lat'].toString()) ??
                                            0.0,
                                        double.tryParse(
                                                event!['long'].toString()) ??
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
