// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/RoomshareDetail.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class RoomshareEvent extends StatefulWidget {
  final int userId;
  final int eventID;
  RoomshareEvent({super.key, required this.userId, required this.eventID});

  @override
  _RoomshareEventState createState() => _RoomshareEventState();
}

class _RoomshareEventState extends State<RoomshareEvent> {
  int _currentIndex = 0;
  bool isLoading = true;

  late Future<List<Map<String, dynamic>>> futureRoomShares;

  @override
  void initState() {
    super.initState();
    futureRoomShares = fetchRoomShares(widget.eventID);
  }

  Future<List<Map<String, dynamic>>> fetchRoomShares(int eventID) async {
    final response = await http.get(
      Uri.parse('$API_ENDPOINT/roomshareevent?eventID=$eventID'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
        .cast<Map<String, dynamic>>()
        .where((room) => room['status'] == "0")
        .toList();
    } else {
      throw Exception('โหลดข้อมูลล้มเหลว');
    }
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final List<dynamic> favArtists = room['favArtists'] ?? [];
       if (widget.userId == room['userId']) {
    return SizedBox.shrink(); 
  }
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(top:10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                    room['photo'] ?? 'https://via.placeholder.com/150'),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 12),
              Row(
                children: [
                  Text(room['name'], style: GoogleFonts.poppins(fontSize: 20)),
                  SizedBox(width: 6),
                  Icon(
                    Icons.verified,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 60, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "อีเว้นท์ : ${room['eventName'] ?? '-'}",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                Text(
                  "เพศ : ${room['gender'] == 'Male' ? 'ชาย' : room['gender'] == 'Female' ? 'หญิง' : room['gender'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                Text(
                  "ต้องการแชร์เพื่อนเพศ : ${room['gender_restrictions'] == 'Male' ? 'ชาย' : room['gender_restrictions'] == 'Female' ? 'หญิง' : room['gender_restrictions'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                Text(
                  "ประเภทห้อง : ${room['typeRoom'] ?? '-'}",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                Text(
                  "ราคาห้องต่อคนที่แชร์ : ${room['price'] ?? '-'} บาท",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                Text(
                  "อื่นๆ : ${room['note'] ?? '-'}",
                  style: GoogleFonts.poppins(),
                  softWrap: true,
                ),
                if (favArtists.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("ศิลปินที่ชอบ:",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: favArtists.map<Widget>((artist) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  artist['artistPhoto'] ??
                                      'https://via.placeholder.com/50'),
                            ),
                            label: Text(artist['artistName'] ?? '-'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Roomsharedetail(
                        userId: widget.userId,
                        roomshareID: room['roomshareID'],
                         fromProfile: false,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      futureRoomShares = fetchRoomShares(widget.eventID);
                    });
                  }
                },
                child: Text(
                  "More",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
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
          onPressed: () => Navigator.pop(context, true),
        ),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Roomshare',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                          (Route<dynamic> route) => false,
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
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureRoomShares,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.black));
                } else if (snapshot.hasError) {
                  return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No RoomShare'));
                }
      
                return Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildRoomCard(snapshot.data![index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Homemember(userId: widget.userId),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistPage(userId: widget.userId),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(userId: widget.userId),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileMember(userId: widget.userId),
                ),
              );
              break;
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: ''),
        ],
      ),
    );
  }
}
