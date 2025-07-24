import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminDetail.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/response/userGetHotelResponse.dart';
import 'package:project_concert_closeiin/model/response/userGetSearchHResponse.dart';
import 'dart:developer' as dev_log;
import 'package:http/http.dart' as http;

class AdminHotelPage extends StatefulWidget {
  final int userId;
  final int hotelID;
  const AdminHotelPage({super.key, required this.userId, required this.hotelID});

  @override
  State<AdminHotelPage> createState() => _AdminHotelPageState();
}

class _AdminHotelPageState extends State<AdminHotelPage> {
  int _currentIndex = 2;
  String _searchHotel = '';
  String url = '';
  bool _isLoading = false;

  List<UserHotelGetResponse> filteredhotelss = [];
  List<UserHotelGetResponse> hotels = [];

  List<UserSearchHGetResponse> filteredhotel = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
      _filterHotelList();
    }).catchError((err) {
      dev_log.log(err.toString());
    });
  }

  void _filterHotelList() async {
    setState(() => _isLoading = true);
    try {
      var response = await http.get(Uri.parse('$API_ENDPOINT/hotelpiont'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          hotels = jsonData.map((e) => UserHotelGetResponse.fromJson(e)).toList();
          filteredhotelss = hotels;
          _isLoading = false;
        });
      } else {
        dev_log.log('Failed to fetch all hotels: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      dev_log.log(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _filterHotelListSearch(String query) async {
    _searchHotel = query;
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        filteredhotel = [];
        _isLoading = false;
      });
    } else {
      try {
        var response = await http.get(Uri.parse('$API_ENDPOINT/search/hotel?query=$query'));
        if (response.statusCode == 200) {
          List<dynamic> jsonData = json.decode(response.body);
          setState(() {
            filteredhotel = jsonData.map((e) => UserSearchHGetResponse.fromJson(e)).toList();
            _isLoading = false;
          });
        } else {
          dev_log.log('Failed to fetch hotels: ${response.statusCode}');
          setState(() {
            filteredhotel = [];
            _isLoading = false;
          });
        }
      } catch (e) {
        dev_log.log(e.toString());
        setState(() {
          filteredhotel = [];
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmDialog(dynamic hotel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ยืนยันการลบ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(80, 50),
                      ),
                      child: const Text('ไม่', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: เพิ่มฟังก์ชันลบข้อมูลโรงแรมที่นี่
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(80, 50),
                      ),
                      child: const Text('ตกลง', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('ออกจากระบบ'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget buildHotelCardFromSearch(UserSearchHGetResponse hotel) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotelName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (hotel.hotelName2.isNotEmpty)
                      Text(
                        hotel.hotelName2,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Admindetail(userId: widget.userId,hotelID: widget.hotelID,),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Detail"),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    hotel.hotelPhoto,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ราคา : เริ่มต้น ${hotel.startingPrice} บาท'),
                      const SizedBox(height: 6),
                      Text('ที่ตั้ง : ${hotel.location}'),
                      const SizedBox(height: 6),
                      Text('โทรศัพท์ : ${hotel.phone}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.facebook, size: 14, color: Color(0xFF4267B2)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              hotel.contact.isEmpty ? 'ไม่มีข้อมูล' : hotel.contact,
                              style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildHotelCardFromHotel(UserHotelGetResponse hotel) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotelName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (hotel.hotelName2.isNotEmpty)
                      Text(
                        hotel.hotelName2,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Admindetail(userId: widget.userId,hotelID: widget.hotelID,),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Detail"),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // child: Image.network(
                  //   // hotel.photo,
                  //   width: 120,
                  //   height: 100,
                  //   fit: BoxFit.cover,
                  //   errorBuilder: (context, error, stackTrace) => Container(
                  //     width: 120,
                  //     height: 100,
                  //     color: Colors.grey[300],
                  //     child: const Icon(Icons.broken_image),
                  //   ),
                  // ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('ราคา : เริ่มต้น ${hotel.price} บาท'),
                      const SizedBox(height: 6),
                      Text('ที่ตั้ง : ${hotel.location}'),
                      const SizedBox(height: 6),
                      Text('โทรศัพท์ : ${hotel.phone}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.facebook, size: 14, color: Color(0xFF4267B2)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              hotel.contact.isEmpty ? 'ไม่มีข้อมูล' : hotel.contact,
                              style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showDeleteConfirmDialog(hotel),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: FaIcon(FontAwesomeIcons.trash, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Ticket';
      case 2:
        return 'Hotel';
      case 3:
        return 'Food';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  Widget _buildNavIcon(Icon icon, int index) {
    bool isSelected = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: isSelected ? const Offset(0, -5) : Offset.zero,
          child: Icon(icon.icon, size: 30, color: Colors.white),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSelected
              ? Text(_getLabel(index), key: ValueKey(index), style: const TextStyle(color: Colors.white, fontSize: 12))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildNavFaIcon(IconData iconData, int index) {
    bool isSelected = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: isSelected ? const Offset(0, -5) : Offset.zero,
          child: FaIcon(iconData, size: 30, color: Colors.white),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSelected
              ? Text(_getLabel(index), key: ValueKey(index), style: const TextStyle(color: Colors.white, fontSize: 12))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Hotel', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _showLogoutDialog),
        ],
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
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
                  onChanged: (value) {
                    _searchHotel = value;
                    _filterHotelListSearch(value);
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final showList = _searchHotel.isNotEmpty ? filteredhotel : filteredhotelss;

                      if (showList.isEmpty) {
                        return Center(child: Text(_searchHotel.isNotEmpty ? 'ไม่พบโรงแรมที่ค้นหา' : 'ไม่มีโรงแรมในระบบ'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: showList.length,
                        itemBuilder: (context, index) {
                          if (_searchHotel.isNotEmpty) {
                            return buildHotelCardFromSearch(showList[index] as UserSearchHGetResponse);
                          } else {
                            return buildHotelCardFromHotel(showList[index] as UserHotelGetResponse);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: _buildNavIcon(const Icon(Icons.home), 0), label: ''),
          BottomNavigationBarItem(icon: _buildNavFaIcon(FontAwesomeIcons.ticket, 1), label: ''),
          BottomNavigationBarItem(icon: _buildNavIcon(const Icon(Icons.hotel), 2), label: ''),
          BottomNavigationBarItem(icon: _buildNavFaIcon(FontAwesomeIcons.utensils, 3), label: ''),
          BottomNavigationBarItem(icon: _buildNavIcon(const Icon(Icons.face), 4), label: ''),
        ],
      ),
    );
  }
}
