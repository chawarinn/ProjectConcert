import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminDetail.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminEvent.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminArtist.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminProfile.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Home.dart';

class AdminHotelPage extends StatefulWidget {
  final int userId;
  const AdminHotelPage({super.key, required this.userId});

  @override
  State<AdminHotelPage> createState() => _AdminHotelPageState();
}

class _AdminHotelPageState extends State<AdminHotelPage> {
  int _currentIndex = 3;
  bool _isLoading = false;
  late String url;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> hotels = [];

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

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/hotelpiont');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          hotels = json.decode(response.body);
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
    final filteredHotels = hotels.where((hotel) {
      final name = (hotel['hotelName'] ?? '').toLowerCase();
      final name2 = (hotel['hotelName2'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || name2.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hotel',
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
              : filteredHotels.isEmpty
                  ? Expanded(
                      child: Center(
                          child:
                              Text('No Hotel', style: TextStyle(fontSize: 18))))
                  : Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredHotels.length,
                        itemBuilder: (context, index) {
                          return buildCard(
                            context,
                            filteredHotels[index],
                            _fetchAll,
                            widget.userId,
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
  dynamic hotel,
  Future<void> Function() onUpdated,
  int userId,
) {
  return Card(
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
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  hotel['hotelName'] ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${hotel['totalPiont'] ?? 0}/',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                  ],
                ),
              ),
            ],
          ),
          if (hotel['hotelName2'] != null &&
              hotel['hotelName2'].toString().isNotEmpty)
            Text(hotel['hotelName2'], style: TextStyle(fontSize: 14)),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hotel['hotelPhoto'] ?? '',
                  width: 120,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 100,
                      color: Colors.grey,
                      child: Icon(Icons.broken_image, color: Colors.white),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'ราคา : เริ่มต้น ${hotel['startingPrice'] ?? 'N/A'} บาท'),
                    SizedBox(height: 6),
                    Text(hotel['location'] ?? ''),
                    SizedBox(height: 6),
                    Text('โทรศัพท์ : ${hotel['phone'] ?? '-'}'),
                    if (hotel['contact'] != null &&
                        hotel['contact'].toString().isNotEmpty) ...[
                      SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "Facebook : "),
                            TextSpan(
                              text: hotel['contact'],
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        builder: (_) => Admindetail(
                            userId: userId, hotelID: hotel['hotelID'])),
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
                icon: Icon(Icons.delete, color: Colors.red, size: 35),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notification'),
                      content: Text('ต้องการลบโรงแรมนี้หรือไม่?'),
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
                      builder: (_) => Center(
                          child:
                              CircularProgressIndicator(color: Colors.black)),
                    );

                    try {
                      final response = await http.delete(Uri.parse(
                        '$API_ENDPOINT/deletehotel?hotelID=${hotel['hotelID']}',
                      ));
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                        );
                        await onUpdated();
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
