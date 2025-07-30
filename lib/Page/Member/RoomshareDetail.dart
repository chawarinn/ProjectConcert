// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/DetailHotel.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class Roomsharedetail extends StatefulWidget {
  final int userId;
  final int roomshareID;
  final bool fromProfile;

  Roomsharedetail({super.key, required this.userId, required this.roomshareID,this.fromProfile = false,});

  @override
  _RoomsharedetailState createState() => _RoomsharedetailState();
}

class _RoomsharedetailState extends State<Roomsharedetail> {
  late int _currentIndex;
  bool isLoading = true;
  Map<String, dynamic>? room;
  bool hasRequested = false;
  int? requestID;

  @override
  void initState() {
    super.initState();
    fetchRoomShares().then((data) async {
      setState(() {
        room = data.firstWhere(
          (r) => r['roomshareID'] == widget.roomshareID,
          orElse: () => {},
        );
      });
      await checkRequestStatus();
      print('widget.userId: ${widget.userId}, room userID: ${room!['userID']}');
      print(
          'widget.userId type: ${widget.userId.runtimeType}, room userID type: ${room!['userID'].runtimeType}');

      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
    _currentIndex = widget.fromProfile ? 3 : 0;
  }

  Future<List<Map<String, dynamic>>> fetchRoomShares() async {
    final response = await http.get(Uri.parse('$API_ENDPOINT/roomshare'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('โหลดข้อมูลล้มเหลว');
    }
  }

  Future<void> checkRequestStatus() async {
    final dbRef = FirebaseDatabase.instance.ref('roomshare_requests');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> requests = snapshot.value as Map;
      requests.forEach((key, value) {
        if (key != 'lastID') {
          if (value['userReqID'] == widget.userId &&
              value['roomshareID'] == widget.roomshareID) {
            setState(() {
              hasRequested = true;
              requestID = int.tryParse(key);
            });
          }
        }
      });
    }
  }

  Future<void> requiredshare() async {
    setState(() {
      isLoading = true;
    });

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    try {
      final lastIDSnapshot =
          await dbRef.child('roomshare_requests/lastID').get();
      int lastID = lastIDSnapshot.exists ? lastIDSnapshot.value as int : 0;
      int newID = lastID + 1;

      final response = await http
          .get(Uri.parse('$API_ENDPOINT/userreq?userID=${widget.userId}'));

      Map<String, dynamic> userData = {};
      Map<String, dynamic> favArtists = {};

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        final favoriteArtists =
            List<Map<String, dynamic>>.from(data['favoriteArtists']);

        userData = {
          'userID': user['userID'],
          'name': user['name'],
          'photo': user['photo'],
          'email': user['email'],
          'gender': user['gender'],
          'phone': user['phone'],
          'status': 0,
        };

        favArtists = {
          for (var artist in favoriteArtists)
            artist['artistID'].toString(): {
              'artistName': artist['artistName'],
              'artistPhoto': artist['artistPhoto'],
            }
        };
      }

      final Map<String, dynamic> requestData = {
  'userReqID': widget.userId,
  'roomshareID': room!['roomshareID'],
  'roomshareContact': room!['shareContact'],
  'userID': room!['userId'],
  'userDetail': userData,
  if (favArtists.isNotEmpty) 'favoriteArtists': favArtists,
};


      // 4. บันทึกลง Firebase
      await dbRef.child('roomshare_requests/$newID').set(requestData);
      await dbRef.child('roomshare_requests/lastID').set(newID);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ส่งคำขอแชร์ห้องสำเร็จ")),
      );
      await checkRequestStatus(); // อัปเดตสถานะ
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cancelRequest() async {
    if (requestID != null) {
      await FirebaseDatabase.instance
          .ref('roomshare_requests/$requestID')
          .remove();
      setState(() {
        hasRequested = false;
        requestID = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ยกเลิกคำขอเรียบร้อยแล้ว")),
      );
    }
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
            'Detail',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : room == null || room!.isEmpty
              ? Center(child: Text('No room data found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.userId.toString() ==
                          room!['userId'].toString())
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              label: Text("Delete Post",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Notification'),
                                    content: Text(
                                        'คุณแน่ใจว่าต้องการลบโพสต์แชร์ห้องนี้หรือไม่?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('No',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text('Yes',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmDelete == true) {
                                  try {
                                    final response = await http.delete(Uri.parse(
                                        '$API_ENDPOINT/deleteroomshare/${widget.roomshareID}'));

                                    if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("ลบโพสต์เรียบร้อยแล้ว")),
                                      );
                                      Navigator.pop(
                                          context, true); // กลับไปหน้าก่อน
                                    } else {
                                      throw Exception(
                                          "ลบไม่สำเร็จ: ${response.body}");
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("เกิดข้อผิดพลาด: $e")),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      if (widget.userId.toString() !=
                          room!['userId'].toString())
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(201, 151, 187, 1),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                if (hasRequested) {
                                  final confirmCancel = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Notification'),
                                      content: Text(
                                          'คุณต้องการยกเลิกคำขอนี้หรือไม่?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text('No',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text('Yes',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmCancel == true) {
                                    await cancelRequest();
                                  }
                                } else {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Notification'),
                                      content: Text(
                                          'คุณต้องการส่งคำขอแชร์ห้องนี้หรือไม่?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text('No',
                          style: TextStyle(color: Colors.black)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text('Yes',
                          style: TextStyle(color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await requiredshare();
                                  }
                                }
                              },
                              child: Text(
                                hasRequested ? "Cancel Request" : "Share",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),

                      if (room!['photo'] != null && room!['photo'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(
                            child: Image.network(
                              room!['photo'],
                              height: 350,
                              width: 270,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey,
                          child: Center(child: Text('No image')),
                        ),

                      SizedBox(height: 10),

                      // Room Details
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room!['name'] ?? '',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "เพศ : ${room!['gender'] == 'Male' ? 'ชาย' : room!['gender'] == 'Female' ? 'หญิง' : room!['gender'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                            Text(
                              "เบอร์โทร : ${room!['userPhone'] ?? '-'}",
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                            Text(
                              "อีเมลล์ : ${room!['email'] ?? '-'}",
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          height: 30,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.only(left: 10, top: 3),
                          child: Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("อีเว้นท์ : ${room!['eventName'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 15)),
                            Text("ศิลปิน : ${room!['artistName'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 15)),
                            Text(
                              "ต้องการแชร์เพื่อนเพศ : ${room!['gender_restrictions'] == 'Male' ? 'ชาย' : room!['gender_restrictions'] == 'Female' ? 'หญิง' : room!['gender_restrictions'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                            Text("ประเภทห้อง : ${room!['typeRoom'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 15)),
                            Text(
                                "ราคาห้องต่อคนที่แชร์ : ${room!['price'] ?? '-'} บาท",
                                style: GoogleFonts.poppins(fontSize: 15)),
                            Text("อื่นๆ : ${room!['note'] ?? '-'}",
                                style: GoogleFonts.poppins(fontSize: 15)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          width: double.infinity,
                          height: 30,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.only(left: 10, top: 3),
                          child: Text(
                            'Hotel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailHotel(
                                  userId: widget.userId,
                                  hotelID: room!['hotelID'],
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                isLoading = false;
                              });
                              fetchRoomShares();
                            }
                          },
                          child: Card(
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
                                  Text(
                                    room!['hotelName'] ?? '',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(room!['hotelName2'] ?? '',
                                      style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          room!['hotelPhoto'],
                                          width: 120,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'ราคา : เริ่มต้น ${room!['startingPrice']} บาท'),
                                            SizedBox(height: 6),
                                            Text(
                                                'ที่ตั้ง : ${room!['hotelLocation']}'),
                                            SizedBox(height: 6),
                                            Text(
                                                'โทรศัพท์ : ${room!['hotelPhone']}'),
                                            SizedBox(height: 6),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: "Facebook : "),
                                                  TextSpan(
                                                    text: room!['hotelcontact'],
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                    builder: (_) => Homemember(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ArtistPage(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NotificationPage(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileMember(userId: widget.userId)),
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
