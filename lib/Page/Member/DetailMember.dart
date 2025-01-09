// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailMember extends StatefulWidget {
  int userId;
  DetailMember({super.key,  required this.userId});
  @override
  _DetailMemberState createState() => _DetailMemberState();
}

class _DetailMemberState extends State<DetailMember> {
  int _currentIndex = 0;
  double _rating = 0; // Variable to hold rating value

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [
      'https://cf.bstatic.com/xdata/images/hotel/max1024x768/252071635.jpg?k=abc123',
      'https://cf.bstatic.com/xdata/images/hotel/max1024x768/252071636.jpg?k=abc123',
      'https://cf.bstatic.com/xdata/images/hotel/max1024x768/252071637.jpg?k=abc123',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.purple.shade200,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'โรงแรม ไอบิส แบงค็อก อิมแพ็ค',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(1, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_rating == index + 1) {
                              _rating =
                                  0; // Reset to 0 if the same star is clicked again
                            } else {
                              _rating = index +
                                  1.0; // Set rating to the clicked star's position
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'ibis Bangkok Impact',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 12), // เอา horizontal padding ออก
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 160, 152, 161),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Align(
                  alignment:
                      Alignment.centerLeft, // จัดตำแหน่งข้อความให้ชิดซ้ายสุด
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16), // เพิ่มระยะห่างจากขอบซ้ายเล็กน้อย
                    child: Text(
                      'รายละเอียด',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ราคา: ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'เริ่มต้น 1,275 บาท',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'ประเภท: ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'เตียงควีนไซส์, เตียงเดี่ยว',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'สิ่งอำนวยความสะดวก: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ตู้บริการสำหรับเตรียมเครื่องดื่ม, บริการโทรปลุก, โต๊ะทำงาน, ตู้เย็น, ทีวีจอแบน, อุปกรณ์ชงชา/กาแฟ, ฯลฯ',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ที่อยู่: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '93 Popular Road, Banmai Subdistrict, NONTHABURI, 11120',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 12), // เอา horizontal padding ออก
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 160, 152, 161),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Align(
                  alignment:
                      Alignment.centerLeft, // จัดตำแหน่งข้อความให้ชิดซ้ายสุด
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16), // เพิ่มระยะห่างจากขอบซ้ายเล็กน้อย
                    child: Text(
                      'แผนที่',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heartPulse),
            label: 'Favorite Artist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
