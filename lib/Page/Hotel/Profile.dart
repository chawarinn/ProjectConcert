// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Hotel/EditProfile.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:get_storage/get_storage.dart';

class ProfileHotel extends StatefulWidget {
  int userId;
  ProfileHotel({super.key, required this.userId});

  @override
  _ProfileHotelState createState() => _ProfileHotelState();
}

class _ProfileHotelState extends State<ProfileHotel> {
  int _currentIndex = 1;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  Future<void> deleteUserAccount() async {
    setState(() {
      _isDeleting = true;
    });

    // แสดง Dialog Loading
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
                    final box = GetStorage();
                        box.erase();
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
      Navigator.pop(context); 
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
           style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20
          ),
        ),
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
                          final box = GetStorage();
                        box.erase();
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
                   Center(
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  'Name',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                userData?['name'] ?? '-',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  'Phone',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                userData?['phone'] ?? '-',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileH(userId: widget.userId)),
                        );
                        if (result == true) {
                          setState(() {
                            isLoading = true;
                          });
                          fetchUserData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    height: 50,
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
                                      style: TextStyle(color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteUserAccount();
                                  },
                                  child: Text('Yes',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
  final box = GetStorage();
  switch (index) {
    case 0:
      await box.write('lastVisitedPage', 'home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomeHotel(userId: widget.userId)),
      );
      break;
    case 1:
      await box.write('lastVisitedPage', 'profileHotel');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>ProfileHotel(userId: widget.userId)),
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
            icon: Icon(Icons.face),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
