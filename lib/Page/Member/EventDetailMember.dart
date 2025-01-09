// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Eventdetailmember extends StatefulWidget {
  int userId;
  Eventdetailmember({super.key,  required this.userId});
  @override
  _EventDetailMemberState createState() => _EventDetailMemberState();
}

class _EventDetailMemberState extends State<Eventdetailmember> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Add more action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity, 
                  height: 300, 
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero, // มุมฉาก
                    image: DecorationImage(
                      image: AssetImage('assets/images/worldwide.png'),
                      fit: BoxFit.cover, // ปรับขนาดรูปให้เต็มพื้นที่
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'NuNew 1st Concert "DREAM CATCHER"',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Chip(
                label: Text('Concert'),
                backgroundColor: Colors.purple.shade100,
              ),
              SizedBox(height: 8),
              Text(
                'NuNew Chawarin\n10 - 11 August 2024\n17:00 - 20:00\nIMPACT Arena Muang Thong Thani',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Ticket page
                    },
                    child: Text('Ticket'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Hotel page
                    },
                    child: Text('Hotel'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'แผนที่',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
                child: Center(
                  child: Text('Map Placeholder'),
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
          if (index == 0) {
            // Navigate to Home
          } else if (index == 1) {
            // Navigate to Favorite Artist Page
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
