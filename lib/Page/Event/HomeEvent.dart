// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // สำหรับจัดรูปแบบวันที่
import 'package:project_concert_closeiin/Page/Event/AddArtist.dart';
import 'package:project_concert_closeiin/Page/Event/AddEvent.dart';
import 'package:project_concert_closeiin/Page/Event/EditEvent.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class HomeEvent extends StatefulWidget {
  final int userId;
  const HomeEvent({super.key, required this.userId});

  @override
  _HomeEventState createState() => _HomeEventState();
}

class _HomeEventState extends State<HomeEvent> {
  int _currentIndex = 0;
  bool _isLoading = false;
  late String url;

  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      print(err);
    });

    _fetchAllEvent();
  }

  Future<void> _fetchAllEvent() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/EventH?userID=${widget.userId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          events = decoded;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat.yMMMMd('th').format(date);
    } catch (e) {
      return dateStr;
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
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: Text('Yes', style: TextStyle(color: Colors.black)),
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
                        HomeEvent(userId : widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AddArtistPage(userId: widget.userId)),
              );
              break;
               case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileEvent(userId: widget.userId)),
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
            icon: Icon(Icons.library_music),
            label: 'Artist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : events.isEmpty
              ? Center(
                  child: Text(
                    'Add your Event',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('Delete / Update',
                            style: TextStyle(fontSize: 25)),
                      ),
                      ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return buildEventCard(
                            context,
                            events[index],
                            _fetchAllEvent,
                            widget.userId,
                            formatDate,
                          );
                        },
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEvent(userId: widget.userId),
            ),
          );
          if (result == true) {
            _fetchAllEvent();
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}

Widget buildEventCard(
  BuildContext context,
  dynamic event,
  Future<void> Function() onEventUpdated,
  int userId,
  String Function(String) formatDate,
) {
  String dateStr = event['date'] ?? '';
  String timeStr = event['time'] ?? '';
  String ltimeStr = event['ltime'] ?? '';

  String displayDate = '';
  String displayTime = '';
  String displayLTime = '';

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
    margin: EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event['eventName'] ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event['eventPhoto'] != null &&
                  event['eventPhoto'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event['eventPhoto'],
                    height: 180,
                    width: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey, width: 140, height: 180),
                  ),
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['typeEventName'] ?? ''),
                    SizedBox(height: 4),
                    Text(displayDate, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text('$displayTime - $displayLTime',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(event['location']),
                    SizedBox(height: 4),
                    Text('Link : ${event['linkticket'] ?? ''}'),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Artist'),
          if (event['artists'] != null && event['artists'] is List)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event['artists'].length,
                itemBuilder: (context, idx) {
                  final artist = event['artists'][idx];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            artist['artistPhoto'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    width: 50, height: 50, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          artist['artistName'] ?? '',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEvent(
                        userId: userId,
                        eventID: event['eventID'],
                      ),
                    ),
                  );
                  if (result == true) {
                    await onEventUpdated();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notification'),
                      content: Text('ต้องการลบอีเวนต์นี้หรือไม่?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child:
                              Text('No', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          Center(child: CircularProgressIndicator(color: Colors.black)),
                    );

                    try {
                      final response = await http.delete(Uri.parse(
                        '$API_ENDPOINT/deleteevent?eventID=${event['eventID']}',
                      ));
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                        );
                        await onEventUpdated();
                      } else {
                        throw Exception('ลบไม่สำเร็จ: ${response.body}');
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
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
