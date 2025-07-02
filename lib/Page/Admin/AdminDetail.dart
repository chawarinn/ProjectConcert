import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Admindetail extends StatefulWidget {
  final int userId;
  const Admindetail({super.key, required this.userId});

  @override
  State<Admindetail> createState() => _AdmindetailState();
}

class _AdmindetailState extends State<Admindetail> {
  int _currentIndex = 2;

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
            // รูปภาพเลื่อนแนวนอน
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
            const Text('รายละเอียด', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('ราคา : เริ่มต้น 1,275 บาท'),
            const SizedBox(height: 8),
            const Text('ประเภท :', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('เตียงควีนไซส์\nเตียงเดี่ยว'),
            const SizedBox(height: 8),
            const Text('สิ่งอำนวยความสะดวก :', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
              'ตู้เย็นสำหรับแช่สินค้า/บริการโทรปลุก,โต๊ะทำงาน\n'
              'ตู้เสื้อผ้า,เฟ้นโซฟา/เก้าอี้,ทีวี,โทรศัพท์ในห้องนอน\n'
              'ผ้าม่าน,อุปกรณ์รีดผ้า,ผ้าปูที่นอน,ผ้าเช็ดตัว/ภาพ\n'
              'ห้องน้ำพร้อมฝักบัว,ผลิตภัณฑ์อาบน้ำ,กล่องทิชชู่,โทรศัพท์,\n'
              'เครื่องทำน้ำอุ่น,ของอาบน้ำฟรี,อ่างอาบน้ำ/ฝักบัวแยก,รองเท้าสวมในห้องพัก,เครื่องปรับอากาศ',
            ),
            const SizedBox(height: 8),
            const Text('ที่อยู่ :', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('93 Popular Road, Banmai Subdistrict, NONTHABURI, 11120'),
            const SizedBox(height: 8),
            const Text('รีวิว : 8.4 คะแนน (อ้างอิงจาก 659 รีวิว)'),
            const SizedBox(height: 16),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: เพิ่มการเปิดแผนที่
              },
              icon: const Icon(Icons.map),
              label: const Text('แผนที่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
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
