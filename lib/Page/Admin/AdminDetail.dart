import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Admindetail extends StatefulWidget {
  final int userId;
  const Admindetail({super.key, required this.userId});

  @override
  State<Admindetail> createState() => _AdmindetailState();
}

class _AdmindetailState extends State<Admindetail> {
  int _currentIndex = 2;
  late GoogleMapController mapController;

  final LatLng _hotelLocation = const LatLng(13.9125, 100.5485); // พิกัดโรงแรม

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
              ? Text(
                  _getLabel(index),
                  key: ValueKey(index),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
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
              ? Text(
                  _getLabel(index),
                  key: ValueKey(index),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณต้องการที่จะออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ไม่'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          width: 300,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRestaurantCard({
    required String image,
    required String name,
    required String category,
    required String address,
    required String distance,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 3,
        child: SizedBox(
          width: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                child: Image.asset(
                  image,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('ประเภทอาหาร: $category'),
                      Text('ที่อยู่: $address'),
                      Text('ระยะทาง: $distance'),
                      Text('เปิดแล้ว: $status',
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Detail', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'โรงแรม ไอบิส แบงค็อค อิมแพ็ค',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('ibis Bangkok Impact'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildImage('assets/images/ibis.jpg'),
                  _buildImage('assets/images/ibis2.jpg'),
                  _buildImage('assets/images/ibis3.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              child: const Text(
                'รายละเอียด',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ราคา : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text('เริ่มต้น 1,275 บาท'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('ประเภท :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('เตียงควีนไซส์\nเตียงเดี่ยว'),
            const SizedBox(height: 8),
            const Text('สิ่งอำนวยความสะดวก :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text(
              'ตู้เย็น, โทรปลุก, โต๊ะทำงาน, ตู้เสื้อผ้า, โซฟา, ทีวี, โทรศัพท์\n'
              'ผ้าม่าน, อุปกรณ์รีดผ้า, ผ้าปูที่นอน, ผ้าเช็ดตัว, ห้องน้ำ, ฝักบัว,\n'
              'เครื่องทำน้ำอุ่น, ของอาบน้ำ, อ่างอาบน้ำ, รองเท้า, แอร์',
            ),
            const SizedBox(height: 8),
            const Text('ที่อยู่ :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('93 Popular Road, Banmai Subdistrict, NONTHABURI, 11120'),
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รีวิว : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text('8.4 คะแนน (อ้างอิงจาก 659 รีวิว)'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // เพิ่ม Google Map
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey.shade300,
              child: const Text(
                'แผนที่',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _hotelLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('hotel'),
                      position: _hotelLocation,
                      infoWindow:
                          const InfoWindow(title: 'ibis Bangkok Impact'),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey.shade300,
              child: const Text(
                'ร้านอาหารใกล้เคียง',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRestaurantCard(
                    image: 'assets/images/restaurant_sample.jpg',
                    name: 'ฮ่องกง ฟิชช์เซอร์เมน',
                    category: 'จีน, อาหารทะเล, สลัด, ก๋วยเตี๋ยว',
                    address: 'อาคาร 8 ศูนย์อาหาร อิมแพ็ค เมืองทองธานี',
                    distance: '0.3 กิโลเมตร',
                    status: 'เปิดให้บริการ !!',
                  ),
                  _buildRestaurantCard(
                    image: 'assets/images/restaurant2.jpg',
                    name: 'ครัวคุณแม่',
                    category: 'ไทย, ข้าวแกง, อาหารจานเดียว',
                    address: 'ซอยข้างอิมแพ็ค อาคาร 2',
                    distance: '0.4 กิโลเมตร',
                    status: 'เปิดให้บริการ !!',
                  ),
                  _buildRestaurantCard(
                    image: 'assets/images/restaurant_sample.jpg',
                    name: 'ร้านตัวอย่าง 3',
                    category: 'อาหารไทย',
                    address: 'ที่อยู่ตัวอย่าง',
                    distance: '0.5 กิโลเมตร',
                    status: 'เปิดให้บริการ !!',
                  ),
                  // ปุ่มเพิ่มเติมแบบวงรี ขนาดพอดีกับตัวหนังสือ
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 12),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          print('กดปุ่มเพิ่มเติม');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[700],
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 2,
                        ),
                        child: const Text(
                          'เพิ่มเติม',
                          style: TextStyle(fontSize: 16),
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
