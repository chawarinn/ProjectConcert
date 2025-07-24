import 'dart:convert';
import 'dart:developer' as dev_log;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/AdminSearchGetResponse.dart';

class AdminRes extends StatefulWidget {
  final int userId;
  const AdminRes({super.key, required this.userId});

  @override
  State<AdminRes> createState() => _AdminResState();
}

class _AdminResState extends State<AdminRes> {
  int _currentIndex = 3;
  String _searchRes = '';
  String url = '';
  bool _isLoading = false;

  List<AdminSearchHGetResponse> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
      fetchAllRestaurants();
    }).catchError((err) {
      dev_log.log(err.toString());
    });
  }
  

  void fetchAllRestaurants() async {
    setState(() => _isLoading = true);
    try {
      var response = await http.get(Uri.parse('$API_ENDPOINT/restaurant'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          filteredRestaurants = jsonData.map((e) => AdminSearchHGetResponse.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        dev_log.log('Failed to fetch all restaurants: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      dev_log.log(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _filterResList(String query) async {
    _searchRes = query;
    setState(() => _isLoading = true);

    if (query.isEmpty) {
      fetchAllRestaurants();
      return;
    }

    try {
      var response = await http.get(Uri.parse('$API_ENDPOINT/search/restaurant?query=$query'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          filteredRestaurants = jsonData.map((e) => AdminSearchHGetResponse.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        dev_log.log('Failed to fetch restaurants: ${response.statusCode}');
        setState(() {
          filteredRestaurants = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      dev_log.log(e.toString());
      setState(() {
        filteredRestaurants = [];
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('ออกจากระบบ')),
        ],
      ),
    );
  }

  Widget buildCard(AdminSearchHGetResponse item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.resPhoto,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.resName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('ประเภทอาหาร: ${item.type}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('เปิด: ${item.open}'),
                      Text('ปิด: ${item.close}'),
                      Text('ที่อยู่: ${item.location}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text(
                        'ติดต่อ: ${item.contact.isNotEmpty ? item.contact : 'ยังไม่หาเบอร์ !!!'}',
                        style: TextStyle(
                          color: item.contact.isNotEmpty ? Colors.black : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                final confirm = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: const Color(0xFFD09DBD),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Confirm Delete',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (confirm == true) {
                  try {
                    final response = await http.delete(
                      Uri.parse('$API_ENDPOINT/deleterestaurant/${item.resID}'),
                    );
                    if (response.statusCode == 200) {
                      setState(() {
                        filteredRestaurants.remove(item);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ลบร้านอาหารสำเร็จ')),
                      );
                    } else if (response.statusCode == 404) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ไม่พบร้านอาหารนี้')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.statusCode}')),
                      );
                    }
                  } catch (e) {
                    dev_log.log('Delete error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์')),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: const Icon(FontAwesomeIcons.trash, color: Colors.red, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Restaurants', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _showLogoutDialog),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                height: 40,
                child: TextField(
                  onChanged: (value) => _filterResList(value),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) => buildCard(filteredRestaurants[index]),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          // TODO: เปลี่ยนหน้าตาม index ที่เลือก
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.ticket), label: 'Ticket'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotel'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.utensils), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
