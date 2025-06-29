import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeAdmin extends StatefulWidget {
  final int userId;
  const HomeAdmin({super.key, required this.userId});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _currentIndex = 2;

  Widget _buildNavIcon(Icon icon, int index) {
    bool isSelected = _currentIndex == index;
    return Transform.translate(
      offset: isSelected ? const Offset(0, -5) : Offset.zero,
      child: icon,
    );
  }

  Widget _buildNavFaIcon(IconData iconData, int index) {
    bool isSelected = _currentIndex == index;
    return Transform.translate(
      offset: isSelected ? const Offset(0, -5) : Offset.zero,
      child: FaIcon(iconData),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ออกจากระบบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ออกจากระบบ'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
                // TODO: เปลี่ยนเส้นทางกลับไปหน้า login หรือ home page
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
      ),
      body: const Center(
        child: Text("Hotel Page", style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
       backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              break;
            case 2:
              break;
            case 3:
              break;
            case 4:
              break;
          }
        },
        
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(const Icon(Icons.home), 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavFaIcon(FontAwesomeIcons.ticket, 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(const Icon(Icons.hotel), 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavFaIcon(FontAwesomeIcons.utensils, 3),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(const Icon(Icons.face), 4),
            label: '',
          ),
        ],
      ),
    );
  }
}
