import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/EventDetailMember.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class Event extends StatefulWidget {
  int userId;
  Event({super.key, required this.userId});

  @override
  _Event createState() => _Event();
}

class _Event extends State<Event> {
  int _currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> eventList = [];
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

  Future<void> searchEvent(String query) async {
    if (query.isEmpty) {
      fetchEvent();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$API_ENDPOINT/search/event?query=$query'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          eventList = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to search events');
      }
    } catch (e) {
      log('Search events error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildEventCard(dynamic event) {
    String dateStr = event['date'] ?? '';
    String timeStr = event['time'] ?? '';
    String ltimeStr = event['ltime'] ?? '';

    String displayDate = '';
    String displayTime = '';
    String displayLTime = '';

    try {
      final dt = DateTime.parse(dateStr);
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
      displayDate = '${dt.day} ${thaiMonths[dt.month]} ${dt.year}';
    } catch (_) {
      displayDate = dateStr;
    }

    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        displayTime = '$hour:$minute';
      }
    } catch (_) {
      displayTime = timeStr;
    }

    try {
      final parts = ltimeStr.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        displayLTime = '$hour:$minute น.';
      }
    } catch (_) {
      displayLTime = ltimeStr;
    }

    return Card(
      color: Colors.grey[200],
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                event['eventPhoto'] ?? '',
                width: 120,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 170,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventName'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(displayDate, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text('$displayTime - $displayLTime',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(event['location'] ?? '',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                builder: (context) => Eventdetailmember(
                                    userId: widget.userId,
                                    eventID: event['eventID'])),
                          );
                          if (result == true) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        fetchEvent();
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
                          'Detail',
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
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
         onPressed: () {
    Navigator.pop(context, true); 
  },
        ),
        title: Text(
          'Event',
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
                 builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ยืนยันการออกจากระบบ'),
                    content: const Text('คุณต้องการที่จะออกจากระบบหรือไม่?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('ไม่'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const homeLogoPage()));
                        },
                        child: const Text('ตกลง'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 200,
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchQuery = value;
                    searchEvent(searchQuery);
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
            ),
          ),
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (eventList.isEmpty)
            Expanded(
              child: Center(
                child: Text('No events found'),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: eventList
                        .map((event) => buildEventCard(event))
                        .toList(),
                  ),
                ),
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
}
