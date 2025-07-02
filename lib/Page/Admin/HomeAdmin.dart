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

  // ปรับให้แสดงชื่อใต้ไอคอนและยังขยับขึ้นได้ มี animation เด้ง label
  Widget _buildNavIcon(Icon icon, int index) {
    bool isSelected = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: isSelected ? const Offset(0, -5) : Offset.zero,
          child: Icon(
            icon.icon,
            size: 30,
            color: Colors.white,
          ),
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
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
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
          child: FaIcon(
            iconData,
            size: 30,
            color: Colors.white,
          ),
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
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
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
                Navigator.of(context).pop();
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
