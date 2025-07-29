// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:project_concert_closeiin/Page/Admin/AdminArtist.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminEventDetail.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminProfile.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class AdminEvent extends StatefulWidget {
  final int userId;
  const AdminEvent({super.key, required this.userId});

  @override
  State<AdminEvent> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEvent> {
  int _currentIndex = 1;
  bool _isLoading = false;
  late String url;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      print(err);
    });
    _fetchAll();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat.yMMMMd('th').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/EventAdmin');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    final filteredEvents = events.where((event) {
      final name = (event['eventName'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Event',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:
                            Text('No', style: TextStyle(color: Colors.black))),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => homeLogoPage())),
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
          setState(() => _currentIndex = index);
          Widget page;
          switch (index) {
            case 0:
              page = HomeAdmin(userId: widget.userId);
              break;
            case 1:
              page = AdminEvent(userId: widget.userId);
              break;
            case 2:
              page = AdminArtistPage(userId: widget.userId);
              break;
            case 3:
              page = AdminHotelPage(userId: widget.userId);
              break;
            case 4:
              page = AdminRes(userId: widget.userId);
              break;
            case 5:
              page = ProfileAdmin(userId: widget.userId);
              break;
            default:
              return;
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => page));
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.ticket), label: 'Event'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music), label: 'Artist'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotel'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.utensils), label: 'Restaurant'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)))
              : filteredEvents.isEmpty
                  ? Expanded(
                      child: Center(
                          child:
                              Text('No User', style: TextStyle(fontSize: 18))))
                  : Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          return buildCard(
                            context,
                            filteredEvents[index],
                            _fetchAll,
                            widget.userId,
                            formatDate,
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

Widget buildCard(
  BuildContext context,
  dynamic event,
  Future<void> Function() onUpdated,
  int userId,
  String Function(String) formatDate,
) {
  String displayDate = '';
  try {
    final dt = DateTime.parse(event['date'] ?? '').toLocal();
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
    displayDate = event['date'] ?? '';
  }

  String displayTime = (event['time'] ?? '').split(':').take(2).join(':');
  String displayLTime =
      (event['ltime'] ?? '').split(':').take(2).join(':') + ' น.';

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
              if ((event['eventPhoto'] ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event['eventPhoto'],
                    height: 180,
                    width: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
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
                    Text(displayDate),
                    SizedBox(height: 4),
                    Text('$displayTime - $displayLTime'),
                    SizedBox(height: 4),
                    Text(event['location'] ?? ''),
                    SizedBox(height: 4),
                    Text('${event['linkticket'] ?? ''}'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            (event['artists'] != null &&
                                    event['artists'] is List
                                ? (event['artists'] as List)
                                    .map((artist) => artist['artistName'] ?? '')
                                    .where((name) => name.isNotEmpty)
                                    .join(', ')
                                : ''),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AdminEventDetail(
                            userId: userId, eventID: event['eventID'])),
                  );
                  if (result == true) await onUpdated();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 4),
                ),
                child: Text('Detail',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 35,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Notification'),
                      content: Text('ต้องการลบอีเวนต์นี้หรือไม่?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('No',
                                style: TextStyle(color: Colors.black))),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Yes',
                                style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                            child: CircularProgressIndicator(
                                color: Colors.black)));
                    try {
                      final res = await http.delete(Uri.parse(
                          '$API_ENDPOINT/deleteevent?eventID=${event['eventID']}'));
                      Navigator.pop(context);
                      if (res.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ลบเรียบร้อยแล้ว')));
                        await onUpdated();
                      } else {
                        throw Exception('ลบไม่สำเร็จ: ${res.body}');
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
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
