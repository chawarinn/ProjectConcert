// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  NotificationPage({super.key, required this.userId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _currentIndex = 2;
  String url = '';
  String selectedTab = 'All';
  final DatabaseReference rating =
      FirebaseDatabase.instance.ref().child('roomshare_requests');
  List<Map<String, dynamic>> roomRequests = [];
  bool isLoading = true;
  late Stream<DatabaseEvent> _roomRequestStream;
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  @override
void initState() {
  super.initState();

  Configuration.getConfig().then((config) {
    setState(() {
      url = config['apiEndpoint'];
    });
  }).catchError((err) {
    log(err.toString());
  });

  // ✅ ซ่อน loading หลัง 1 วินาที (แสดงครั้งเดียว)
  Future.delayed(Duration(seconds: 1), () {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  });

  _roomRequestStream = rating.onValue;
  _subscription = _roomRequestStream.listen((DatabaseEvent event) {
    final snapshot = event.snapshot;
    if (!snapshot.exists) {
      setState(() {
        roomRequests = [];
      });
      return;
    }

    final rawData = snapshot.value;
    if (rawData is Map<dynamic, dynamic>) {
      final List<Map<String, dynamic>> requests = [];

      rawData.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          if (value['userReqID'] != null &&
                  value['userReqID'] == widget.userId ||
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
              'status': value['status'] ?? 'request',
              'roomshareContact': value['roomshareContact'] ?? '',
              'updatedAt': value['updatedAt'],
            });
          }
        }
      });

      // 🔽 จัดเรียง
      requests.sort((a, b) {
        final statusA = a['status'] ?? '';
        final statusB = b['status'] ?? '';
        final updatedA = a['updatedAt'] ?? 0;
        final updatedB = b['updatedAt'] ?? 0;

        if (updatedA != updatedB) return updatedB.compareTo(updatedA);
        if (statusA == 'accepted' && statusB == 'cancelled') return -1;
        if (statusA == 'cancelled' && statusB == 'accepted') return 1;

        return b['key'].compareTo(a['key']);
      });

      setState(() {
        roomRequests = requests;
      });
    } else {
      setState(() {
        roomRequests = [];
      });
    }
  });
}


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredRequests {
    final filtered = roomRequests.where((r) {
      final isSelfRequest = r['userReqID'] == widget.userId;
      final status = r['status'];
      if (isSelfRequest && (status == null || status == 'request')) {
        return false;
      }
      return true;
    }).toList();

    if (selectedTab == 'Requests') {
      return filtered
          .where((r) => r['status'] == null || r['status'] == 'request')
          .toList();
    } else if (selectedTab == 'Accepted') {
      return filtered.where((r) => r['status'] == 'accepted').toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
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
                      child: const Text('No',
                          style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',
                          style: TextStyle(color: Colors.black)),
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
                    builder: (context) => ProfileMember(userId: widget.userId)),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heartPulse), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: ''),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10),
            child: Row(
              children: [
                FilterButton(
                  label: 'All',
                  selected: selectedTab == 'All',
                  onTap: () => setState(() => selectedTab = 'All'),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Requests',
                  selected: selectedTab == 'Requests',
                  onTap: () => setState(() => selectedTab = 'Requests'),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  label: 'Accepted',
                  selected: selectedTab == 'Accepted',
                  onTap: () => setState(() => selectedTab = 'Accepted'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : filteredRequests.isEmpty
                    ? Center(child: Text('No notifications'))
                    : ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          return RoomShareRequestCard(
                            request: filteredRequests[index],
                            userId: widget.userId,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Color(0xFFC997BB) : Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class RoomShareRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final int userId;

  const RoomShareRequestCard({
    required this.request,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final userDetail = request['userDetail'];
    final photo = userDetail?['photo'] ?? 'https://via.placeholder.com/150';
    final name = userDetail?['name'] ?? 'Unknown';
    final gender = userDetail?['gender'] ?? '-';
    final phone = userDetail?['phone'] ?? '-';
    final email = userDetail?['email'] ?? '-';
    final artists = request['favoriteArtists'] as List<String>;
    final status = request['status'] ?? '';
    final roomshareContact = request['roomshareContact'] ?? '';

    Future<List<Map<String, dynamic>>> fetchRoomShares() async {
      final roomshareID = request['roomshareID'];
      final response = await http.get(
          Uri.parse('$API_ENDPOINT/roomshareNoti?roomshareID=$roomshareID'));
      ;

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data
            .cast<Map<String, dynamic>>()
            .where((room) => room['status'] == "1")
            .toList();
      } else {
        throw Exception('โหลดข้อมูลล้มเหลว');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Card(
        color: Color(0xFFF1F1F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status == 'accepted') ...[
                 if (request['userReqID'] == userId) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 30),
                      const SizedBox(width: 6),
                      Text(
                        'Accepted Room sharing successful',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Room sharing successful',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]
               
              ] else if (status == 'cancelled') ...[
                if (request['userReqID'] == userId) ...[
                  Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 30),
                      const SizedBox(width: 6),
                      Text(
                        'Your request has been rejected',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Room sharing failed',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]
              ] else ...[
                Text(
                  'Do You Want Match Room Share ?',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
              if (request['userReqID'] != userId)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircleAvatar(
                          radius: 30, backgroundImage: NetworkImage(photo)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(name,
                                  style: GoogleFonts.poppins(fontSize: 20)),
                              SizedBox(width: 6),
                              Icon(Icons.verified,
                                  color: Colors.blueAccent, size: 20),
                            ],
                          ),
                          Text(
                              "เพศ : ${gender == 'Male' ? 'ชาย' : gender == 'Female' ? 'หญิง' : gender == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                              style: GoogleFonts.poppins(fontSize: 15)),
                          Text("เบอร์โทร : $phone",
                              style: GoogleFonts.poppins(fontSize: 15)),
                          Text("อีเมลล์ : $email",
                              style: GoogleFonts.poppins(fontSize: 15)),
                          Text(
                            'ศิลปิน : ${artists.isNotEmpty ? artists.join(', ') : '-'}',
                            style: GoogleFonts.poppins(fontSize: 15),
                          ),
                          if (status == 'accepted')
                            Text(
                              '',
                            )
                          else if (status == 'cancelled')
                            Text(
                              '',
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseDatabase.instance
                                        .ref(
                                            'roomshare_requests/${request['key']}')
                                        .update({
                                      'status': 'cancelled',
                                      'updatedAt':
                                          DateTime.now().millisecondsSinceEpoch,
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('ปฏิเสธคำขอเรียบร้อยแล้ว')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFC997BB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  child: Text('No',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    final roomshareID = request['roomshareID'];

                                    try {
                                      await FirebaseDatabase.instance
                                          .ref(
                                              'roomshare_requests/${request['key']}')
                                          .update({
                                        'status': 'accepted',
                                        'updatedAt': DateTime.now()
                                            .millisecondsSinceEpoch,
                                      });

                                      final allSnapshot = await FirebaseDatabase
                                          .instance
                                          .ref('roomshare_requests')
                                          .once();

                                      if (allSnapshot.snapshot.value is Map) {
                                        final data =
                                            allSnapshot.snapshot.value as Map;
                                        for (final entry in data.entries) {
                                          final key = entry.key;
                                          final value = entry.value;
                                          if (value is Map &&
                                              value['roomshareID'] ==
                                                  roomshareID &&
                                              key != request['key'] &&
                                              value['status'] != 'accepted') {
                                            await FirebaseDatabase.instance
                                                .ref('roomshare_requests/$key')
                                                .update(
                                                    {'status': 'cancelled'});
                                          }
                                        }
                                      }

                                      final response = await http.post(
                                        Uri.parse(
                                            '$API_ENDPOINT/updatestatusroomshare'),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: jsonEncode({
                                          'roomshareID': roomshareID,
                                          'status': 1,
                                        }),
                                      );

                                      if (response.statusCode == 200) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('ตอบรับคำขอสำเร็จ')),
                                        );
                                      } else {
                                        log('Update SQL failed: ${response.body}');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'อัปเดต RoomShare ไม่สำเร็จ')),
                                        );
                                      }
                                    } catch (e) {
                                      log('Error: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'เกิดข้อผิดพลาด: ${e.toString()}')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFC997BB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  child: Text('Yes',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchRoomShares(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('เกิดข้อผิดพลาดในการโหลดข้อมูลห้อง');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('');
                    }
                    final room = snapshot.data!.first;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircleAvatar(
                          radius: 30, backgroundImage: NetworkImage(room['photo'] )),
                    ),
                         const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Row(
                          children: [
                            Text(room['name'] ,
                                style: GoogleFonts.poppins(fontSize: 20)),
                            SizedBox(width: 6),
                            Icon(Icons.verified,
                                color: Colors.blueAccent, size: 20),
                          ],
                        ),
                         Text("โปรดติดต่อ : ${room['shareContact'] ?? '-'}",
                                  style: GoogleFonts.poppins()),
                              Text("อีเว้นท์ : ${room['eventName'] ?? '-'}",
                                  style: GoogleFonts.poppins()),
                              Text("ศิลปิน : ${room['artistName'] ?? '-'}",
                                  style: GoogleFonts.poppins()),
                              Text(
                                  "เพศ : ${room['gender'] == 'Male' ? 'ชาย' : room['gender'] == 'Female' ? 'หญิง' : room['gender'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                                  style: GoogleFonts.poppins()),
                              Text(
                                  "ต้องการแชร์เพื่อนเพศ : ${room['gender_restrictions'] == 'Male' ? 'ชาย' : room['gender_restrictions'] == 'Female' ? 'หญิง' : room['gender_restrictions'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                                  style: GoogleFonts.poppins()),
                              Text("ประเภทห้อง : ${room['typeRoom'] ?? '-'}",
                                  style: GoogleFonts.poppins()),
                              Text(
                                  "ราคาห้องต่อคนที่แชร์ : ${room['price'] ?? '-'} บาท",
                                  style: GoogleFonts.poppins()),
                              Text("อื่นๆ : ${room['note'] ?? '-'}",
                                  style: GoogleFonts.poppins()),
                                  if (status == 'cancelled' &&
                              request['userReqID'] == userId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Rejected',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                             else if (status == 'accepted' &&
                              request['userReqID'] == userId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Accepted',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                            ],
                          ),
                        ),
                         
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
