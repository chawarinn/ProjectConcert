// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Restaurant/AddRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/EditRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/ProfileRestaurant.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'dart:io';

class Homerestaurant extends StatefulWidget {
  final int userId;
  const Homerestaurant({super.key, required this.userId});

  @override
  _HomerestaurantState createState() => _HomerestaurantState();
}

class _HomerestaurantState extends State<Homerestaurant> {
  int _currentIndex = 0;
  bool _isLoading = false;
  late String url;

  List<dynamic> restaurants = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      print(err);
    });

    _fetchAllRestaurant();
  }

  Future<void> _fetchAllRestaurant() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/reshome?userID=${widget.userId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          restaurants = json.decode(response.body);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20
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
                        Homerestaurant(userId : widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileRestaurant(userId: widget.userId)),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : restaurants.isEmpty
              ? Center(
                  child: Text(
                    'Add your Restaurant',
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
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          return buildRestaurantCard(
                            context,
                            restaurants[index],
                            _fetchAllRestaurant,
                            widget.userId,
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
              builder: (context) => AddRestaurant(userId: widget.userId,),
            ),
          );
          if (result == true) {
            _fetchAllRestaurant();
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}

Widget buildRestaurantCard(
  BuildContext context,
  dynamic res,
  Future<void> Function() onRestaurantUpdated,
  int userId,
) {
  return Card(
    color: Colors.grey[200],
    margin: EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(res['resName'] ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (res['resPhoto'] != null)
            Image.network(
              res['resPhoto'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) {
            return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[400],
                      child: Icon(Icons.image, color: Colors.white),
                    );
                       }
            ),
          SizedBox(height: 8),
          Text('ประเภทอาหาร : ${res['type'] ?? ''}'),
          Text('เวลา : ${res['open'] ?? ''} - ${res['close'] ?? ''} น.'),
          Text('ที่ตั้ง : ${res['location'] ?? ''}'),
          Text('ติดต่อ : ${res['contact'] ?? ''}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditRestaurant(
                        userId: userId,
                        resID: res['resID'],
                      ),
                    ),
                  );
                  if (result == true) {
                    await onRestaurantUpdated();
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
                      content: Text('ต้องการลบร้านอาหารนี้หรือไม่?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('No',
                          style: TextStyle(color: Colors.black)),
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
                        '$API_ENDPOINT/deleterestaurant?resID=${res['resID']}',
                      ));
                      Navigator.pop(context); 

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                        );
                        await onRestaurantUpdated();
                      } else {
                        throw Exception('ลบไม่สำเร็จ: ${response.body}');
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ')),
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
