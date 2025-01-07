// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Homemember extends StatefulWidget {
  @override
  _HomeMember createState() => _HomeMember();
}

class _HomeMember extends State<Homemember> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Concert Close Inn',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 190, 150, 198),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar and Icons
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 18,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.search, color: Colors.grey),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIconWithLabel(
                            FontAwesomeIcons.ticketAlt,
                            "Event",
                          ),
                          _buildIconWithLabel(
                            FontAwesomeIcons.hotel,
                            "Hotel",
                          ),
                          _buildIconWithLabel(
                            FontAwesomeIcons.bed,
                            "Room Share",
                          ),
                          _buildIconWithLabel(
                            FontAwesomeIcons.utensils,
                            "Restaurant",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Event Section
              Text(
                'Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200, // กำหนดความสูงของ Event Section
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // เลื่อนซ้าย-ขวา
                  itemCount: 5, // จำนวนอีเว้นท์ (ปรับจำนวนตามข้อมูล)
                  itemBuilder: (context, index) {
                    return _buildEventCard(
                        'assets/event${index + 1}.jpg'); // ใช้ภาพอีเว้นท์
                  },
                ),
              ),

              SizedBox(height: 20),
              // Top 5 Hotel Section
              Text(
                'Top 5 Hotel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildHotelCard();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple.shade200,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // Navigate to Home
          } else if (index == 1) {
            // Navigate to Favorite Artist
          } else if (index == 2) {
            // Navigate to Notifications
          } else if (index == 3) {
            // Navigate to Profile
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heartPulse),
              label: 'Favorite Artist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildIconWithLabel(IconData iconData, String label) {
    return Column(
      children: [
        Icon(iconData, size: 40, color: Colors.black),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildEventCard(String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          color: Colors.grey.shade300,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: Icon(Icons.image, size: 50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'โรงแรม ไอบิส แบงค็อก อิมแพ็ค',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ibis Bangkok Impact',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ราคา : เริ่มต้น 1,275 บาท',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'ที่ตั้ง : 93 Popular Road, Banmai Subdistrict, NONTHABURI, 11120',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'โทรศัพท์ : 020117777',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Facebook : ibis Bangkok Impact',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
