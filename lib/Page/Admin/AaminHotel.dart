import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHotelPage extends StatefulWidget {
  final int userId;
  const AdminHotelPage({super.key, required this.userId});

  @override
  State<AdminHotelPage> createState() => _AdminHotelPageState();
}

class _AdminHotelPageState extends State<AdminHotelPage> {
  int _currentIndex = 2;
  String _searchHotel = '';
  bool _isLoading = false;

  List<Map<String, dynamic>> hotels = [
    {
      'name': 'โรงแรมสวยงาม',
      'totalPiont': 4,
      'name2': 'The Beautiful Hotel',
      'photo': 'https://picsum.photos/80/70',
      'price': 1500,
      'location': 'กรุงเทพฯ',
      'phone': '0123456789',
      'contact': 'fb.com/beautifulhotel',
      'distance': 2.5,
    },
    {
      'name': 'โรงแรมสบาย',
      'totalPiont': 3,
      'name2': 'Comfort Hotel',
      'photo': 'https://picsum.photos/80/70',
      'price': 800,
      'location': 'เชียงใหม่',
      'phone': '0987654321',
      'contact': '',
      'distance': 5.1,
    },
  ];
  List<Map<String, dynamic>> filteredhotels = [];
  List<Map<String, dynamic>> filteredhotel = [];

  @override
  void initState() {
    super.initState();
    filteredhotels = hotels;
  }

  void _filterHotelList(String keyword) {
    setState(() {
      filteredhotel = hotels
          .where((hotel) => hotel['name']
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();
    });
  }

  Widget buildHotelCard(Map<String, dynamic> hotel) {
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hotel['name'] ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if ((hotel['name2'] ?? '').isNotEmpty)
              Text(hotel['name2'], style: TextStyle(fontSize: 14)),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    hotel['photo'] ?? 'https://picsum.photos/80/70',
                    width: 80,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ราคา : เริ่มต้น ${hotel['price']} บาท',
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hotel['location'] ?? '',
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'โทรศัพท์ : ${hotel['phone'] ?? ''}',
                        softWrap: true,
                      ),
                      if ((hotel['contact'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Facebook : ${hotel['contact']}',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                          softWrap: true,
                        ),
                      ],
                      if ((hotel['distance'] ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'ระยะห่าง : ${(hotel['distance'] as num).toStringAsFixed(2)} กม.',
                            softWrap: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
  alignment: Alignment.bottomRight,
  child: GestureDetector(
    onTap: () {
      _showDeleteConfirmDialog(hotel);
    },
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ลบโรงแรม'),
        content: Text('คุณต้องการลบโรงแรม "${hotel['name']}" หรือไม่?'),
        actions: [
          TextButton(
            child: Text('ยกเลิก'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('ลบ'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteHotel(hotel);
            },
          ),
        ],
      ),
    );
  }

  void _deleteHotel(Map<String, dynamic> hotel) {
    setState(() {
      hotels.remove(hotel);
      filteredhotels = hotels;
      filteredhotel = hotels
          .where((h) => h['name']
              .toString()
              .toLowerCase()
              .contains(_searchHotel.toLowerCase()))
          .toList();
    });
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
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation);
            final scaleAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
          child: isSelected
              ? Text(
                  _getLabel(index),
                  key: ValueKey('label_$index'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
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
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation);
            final scaleAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
          child: isSelected
              ? Text(
                  _getLabel(index),
                  key: ValueKey('label_$index'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 180,
                height: 40,
                child: TextField(
                  onChanged: (value) {
                    _searchHotel = value;
                    _filterHotelList(value);
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 20),
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
                ? Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      if (_searchHotel.isNotEmpty) {
                        if (filteredhotel.isEmpty) {
                          return Center(child: Text('ไม่พบโรงแรมที่ค้นหา'));
                        } else {
                          return ListView.builder(
                            itemCount: filteredhotel.length,
                            itemBuilder: (context, index) {
                              var hotel = filteredhotel[index];
                              return buildHotelCard(hotel);
                            },
                          );
                        }
                      } else {
                        if (filteredhotels.isEmpty) {
                          return Center(child: Text('ไม่มีโรงแรมในระบบ'));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              itemCount: filteredhotels.length,
                              itemBuilder: (context, index) {
                                var hotel = filteredhotels[index];
                                return buildHotelCard(hotel);
                              },
                            ),
                          );
                        }
                      }
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
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: _buildNavIcon(const Icon(Icons.home), 0), label: ''),
          BottomNavigationBarItem(
              icon: _buildNavFaIcon(FontAwesomeIcons.ticket, 1), label: ''),
          BottomNavigationBarItem(
              icon: _buildNavIcon(const Icon(Icons.hotel), 2), label: ''),
          BottomNavigationBarItem(
              icon: _buildNavFaIcon(FontAwesomeIcons.utensils, 3), label: ''),
          BottomNavigationBarItem(
              icon: _buildNavIcon(const Icon(Icons.face), 4), label: ''),
        ],
      ),
    );
  }
}
