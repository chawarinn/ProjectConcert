// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/EditProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/RoomshareDetail.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class ProfileMember extends StatefulWidget {
  int userId;
  ProfileMember({super.key, required this.userId});

  @override
  _ProfileMemberState createState() => _ProfileMemberState();
}

class _ProfileMemberState extends State<ProfileMember> {
  int _currentIndex = 3;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  bool _isDeleting = false;
  late Future<List<Map<String, dynamic>>> futureRoomShares;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    futureRoomShares = fetchRoomShares();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('$API_ENDPOINT/user?userID=${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('User not found or error occurred: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRoomShares() async {
    final response = await http.get(Uri.parse('$API_ENDPOINT/roomshare'));

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

  Future<void> deleteUserAccount() async {
    setState(() {
      _isDeleting = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: Colors.black),
        );
      },
    );

    final url =
        Uri.parse('$API_ENDPOINT/deleteAccount?userID=${widget.userId}');

    try {
      final response = await http.delete(url);

      Navigator.pop(context); // ปิด dialog loading

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Notification"),
            content: Text("บัญชีของคุณถูกลบเรียบร้อยแล้ว"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => homeLogoPage()),
                    (route) => false,
                  );
                },
                child: Text("OK", style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        );
      } else {
        final error = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Notification"),
            content: Text(error['message'] ?? 'ไม่สามารถลบบัญชีได้'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // ปิด dialog loading
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    if (widget.userId != room['userId']) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "อีเว้นท์ : ${room['eventName'] ?? '-'}",
                        style: GoogleFonts.poppins(),
                        softWrap: true,
                      ),
                      Text(
                        "ศิลปิน : ${room['artistName'] ?? '-'}",
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Notification'),
                        content: Text(
                            'คุณแน่ใจว่าต้องการลบโพสต์แชร์ห้องนี้หรือไม่?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('No',
                                style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Yes',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                            child:
                                CircularProgressIndicator(color: Colors.black)),
                      );

                      try {
                        final response = await http.delete(Uri.parse(
                          '$API_ENDPOINT/deleteroomshare/${room['roomshareID']}',
                        ));

                        Navigator.pop(context);

                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ลบโพสต์เรียบร้อยแล้ว")),
                          );

                          setState(() {
                            futureRoomShares = fetchRoomShares();
                          });
                        } else {
                          throw Exception("ลบไม่สำเร็จ: ${response.body}");
                        }
                      } catch (e) {
                        Navigator.pop(context); // ปิด loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                        );
                      }
                    }
                  }),
              SizedBox(width: 2),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Roomsharedetail(
                              userId: widget.userId,
                              roomshareID: room['roomshareID'],
                              fromProfile: true,
                            )),
                  );
                  if (result == true) {
                    setState(() {
                      isLoading = true;
                    });
                    fetchUserData();
                    futureRoomShares = fetchRoomShares();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.black,
                    backgroundImage: userData?['photo'] != null
                        ? NetworkImage(userData!['photo'])
                        : null,
                    child: userData?['photo'] == null
                        ? Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? 'No Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData?['email'] ?? 'No Email',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 125),
                            child:
                                Text('Name ', style: TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(userData?['name'] ?? '-',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 125),
                            child:
                                Text('Phone', style: TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(userData?['phone'] ?? '-',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: futureRoomShares,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: Colors.black));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(""));
                      } else {
                        final userRooms = snapshot.data!
                            .where((room) => room['userId'] == widget.userId)
                            .toList();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileMember(
                                                      userId: widget.userId)),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          fetchUserData();
                                          futureRoomShares = fetchRoomShares();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(201, 151, 187, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    width: 200,
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Notification'),
                                              content: Text(
                                                  'คุณแน่ใจหรือไม่ว่าต้องการลบบัญชีนี้? การลบนี้ไม่สามารถย้อนกลับได้'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('No',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    deleteUserAccount();
                                                  },
                                                  child: Text('Yes',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromRGBO(201, 151, 187, 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        'Delete User Account',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (userRooms.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 16, right: 16),
                                child: Column(
                                  children: userRooms
                                      .map((room) => _buildRoomCard(room))
                                      .toList(),
                                ),
                              ),
                          ],
                        );
                      }
                    },
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
