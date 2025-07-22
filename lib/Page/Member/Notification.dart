// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/config.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  NotificationPage({super.key, required this.userId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _currentIndex = 2;
  String url = '';
  final DatabaseReference rating = FirebaseDatabase.instance.ref().child('roomshare_requests');
  List<Map<String, dynamic>> roomRequests = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      log(err.toString());
    });

    fetchReqFirebase();
  }

  Future<void> fetchReqFirebase() async {
     setState(() {
    isLoading = true;
  });

    final snapshot = await rating.get();

    if (!snapshot.exists) {
      log('No roomshare_requests found.');
       setState(() {
      isLoading = false;
    });
      return;
    }

    final rawData = snapshot.value;
    if (rawData is Map<dynamic, dynamic>) {
      final List<Map<String, dynamic>> requests = [];

      rawData.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          if (value['userReqID'] != null &&
              value['userReqID'] != widget.userId &&
              value['userID'] == widget.userId) {
            final favoriteArtists = <String>[];

            final fa = value['favoriteArtists'];
            if (fa != null) {
              if (fa is Map) {
                fa.forEach((_, artist) {
                  if (artist is Map && artist['artistName'] != null) {
                    favoriteArtists.add(artist['artistName']);
                  }
                });
              } else if (fa is List) {
                for (var artist in fa) {
                  if (artist is Map && artist['artistName'] != null) {
                    favoriteArtists.add(artist['artistName']);
                  }
                }
              }
            }

            requests.add({
              'key': key.toString(),
              'roomshareID': value['roomshareID'],
              'userID': value['userID'],
              'userReqID': value['userReqID'],
              'userDetail': value['userDetail'],
              'favoriteArtists': favoriteArtists,
            });
          }
        }
      });

      setState(() {
      roomRequests = requests;
      isLoading = false;
    });
    } else {
      log("Unexpected snapshot format: not a Map");
       setState(() {
      isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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
      body: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: isLoading
      ? Center(child: CircularProgressIndicator())
      : roomRequests.isEmpty
          ? FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 500)),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Center(child: Text('No notifications'));
                }
              },
            )
          : ListView.builder(
              itemCount: roomRequests.length,
              itemBuilder: (context, index) {
                final request = roomRequests[index];
                final userDetail = request['userDetail'];
                final photo = userDetail?['photo'] ?? 'https://via.placeholder.com/150';
                final name = userDetail?['name'] ?? 'Unknown';
                final gender = userDetail?['gender'] ?? '-';
                final phone = userDetail?['phone'] ?? '-';
                final email = userDetail?['email'] ?? '-';
                final artists = request['favoriteArtists'] as List<String>;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Card(
                        color: Color(0xFFF1F1F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Do You Want Match Room Share ?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(radius: 30, backgroundImage: NetworkImage(photo)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(name, style: GoogleFonts.poppins(fontSize: 20)),
                                            SizedBox(width: 6),
                                            Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                                          ],
                                        ),
                                        Text("เพศ : ${gender == 'Male' ? 'ชาย' : gender == 'Female' ? 'หญิง' : gender == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}", style: GoogleFonts.poppins(fontSize: 15)),
                                        Text("เบอร์โทร : $phone", style: GoogleFonts.poppins(fontSize: 15)),
                                        Text("อีเมลล์ : $email", style: GoogleFonts.poppins(fontSize: 15)),
                                        Text('ศิลปิน : ${artists.join(', ')}', style: GoogleFonts.poppins(fontSize: 15)),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFFC997BB),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                              ),
                                              child: Text('No',style: TextStyle(color: Colors.black)),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFFC997BB),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                              ),
                                              child: Text('Yes',style: TextStyle(color: Colors.black)),
                                            ),
                                          ],
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
                    ),
                    Positioned(
                      top: 5,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
                          ],
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.notifications, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                );
              },
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
                MaterialPageRoute(builder: (context) => Homemember(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ArtistPage(userId: widget.userId)),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileMember(userId: widget.userId)),
              );
              break;
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(
            icon:  Icon(Icons.notifications),
                
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: ''),
        ],
      ),
    );
  }
}