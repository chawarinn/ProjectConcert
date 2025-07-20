import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminDetail.dart';

class AdminEvent extends StatefulWidget {
  final int userId;
  const AdminEvent({super.key, required this.userId});

  @override
  State<AdminEvent> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEvent> {
  int _currentIndex = 1;
  String _searchEvent = '';
  bool _isLoading = false;

  List<Map<String, dynamic>> events = [
    {
      'name': 'คอนเสิร์ตดนตรีร็อค',
      'totalPiont': 5,
      'name2': 'Rock Night 2025',
      'photo': 'https://picsum.photos/80/70',
      'price': 1200,
      'location': 'กรุงเทพฯ',
      'phone': '0112345678',
      'contact': 'fb.com/rockconcert',
      'distance': 1.2,
    },
    {
      'name': 'อีเวนต์อาหาร',
      'totalPiont': 4,
      'name2': 'Food Street Festival',
      'photo': 'https://picsum.photos/80/70',
      'price': 300,
      'location': 'เชียงใหม่',
      'phone': '0998765432',
      'contact': '',
      'distance': 3.8,
    },
  ];

  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> filteredEvent = [];

  @override
  void initState() {
    super.initState();
    filteredEvents = List.from(events);
  }

  void _filterEventList(String keyword) {
    setState(() {
      filteredEvent = events
          .where((event) => event['name']
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void _deleteEvent(Map<String, dynamic> event) {
    setState(() {
      events.remove(event);
      filteredEvents = List.from(events);
      if (_searchEvent.isNotEmpty) {
        filteredEvent = events
            .where((e) => e['name']
                .toString()
                .toLowerCase()
                .contains(_searchEvent.toLowerCase()))
            .toList();
      }
    });
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(80, 50),
                      ),
                      child: const Text('ไม่',
                          style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteEvent(event);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(80, 50),
                      ),
                      child: const Text('ตกลง',
                          style: TextStyle(color: Colors.black)),
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

  Widget buildEventCard(Map<String, dynamic> event) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        height: 170, // เพิ่มความสูงจาก 150 เป็น 170
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // รูปภาพทางซ้าย
            ClipRRect(
              borderRadius: BorderRadius.circular(15), // มุมโค้งมนทุกมุม
              child: Image.network(
                event['photo'],
                width: 120,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ข้อมูลงาน (ชื่อ ราคา สถานที่)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((event['name2'] ?? '').isNotEmpty)
                          Text(
                            event['name2'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          '${event['price']} บาท',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    //ทำให้ปุ่มชิดขวา
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ปุ่ม Detail
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Admindetail(userId: widget.userId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              minimumSize: const Size(70, 35),
                            ),
                            child: const Text(
                              "Detail",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),

                          const SizedBox(width: 12),

                          GestureDetector(
                            onTap: () => _showDeleteConfirmDialog(event),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        return 'Event';
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
              ? Text(_getLabel(index),
                  key: ValueKey(index),
                  style: const TextStyle(color: Colors.white, fontSize: 12))
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
              ? Text(_getLabel(index),
                  key: ValueKey(index),
                  style: const TextStyle(color: Colors.white, fontSize: 12))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Event', style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _showLogoutDialog)
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
                    _searchEvent = value;
                    _filterEventList(value);
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, size: 20),
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final showList = _searchEvent.isNotEmpty
                          ? filteredEvent
                          : filteredEvents;
                      if (showList.isEmpty) {
                        return Center(
                            child: Text(_searchEvent.isNotEmpty
                                ? 'ไม่พบอีเวนต์ที่ค้นหา'
                                : 'ไม่มีอีเวนต์ในระบบ'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: showList.length,
                        itemBuilder: (context, index) =>
                            buildEventCard(showList[index]),
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
