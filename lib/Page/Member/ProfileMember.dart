// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileMember extends StatefulWidget {
  int userId;
  ProfileMember({super.key,  required this.userId});
  @override
  _ProfileMemberState createState() => _ProfileMemberState();
}

class _ProfileMemberState extends State<ProfileMember> {
  int _currentIndex = 0; // เก็บสถานะ index ที่ถูกเลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile' ,
        style:
              TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
        backgroundColor: Color.fromARGB(255, 190, 150, 198),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Add action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Mild Pijittra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'pijittra12@gmail.com',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Name: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mild Pijittra',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Phone: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '0987654321',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Add edit action
              },
              child: Text(
                'Edit',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Add delete account action
              },
              child: Text(
                'Delete User Account',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // ระบุไอคอนที่เลือก
        selectedItemColor: Colors.purple.shade200,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // อัปเดตสถานะเมื่อคลิก
          });
          if (index == 0) {
            // Navigate to Home
          } else if (index == 1) {
            // Navigate to ECG Heart Page
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
              label: 'Favorite Atrist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
        ],
      ),
    );
  }
}
