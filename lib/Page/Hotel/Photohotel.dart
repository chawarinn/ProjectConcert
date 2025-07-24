import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HomeHotel.dart';
import 'Profile.dart';

class Photohotel extends StatefulWidget {
  final int userId;
  final int hotelID;

  const Photohotel({super.key, required this.userId, required this.hotelID});

  @override
  State<Photohotel> createState() => _PhotohotelState();
}

class _PhotohotelState extends State<Photohotel> {
  List<File> _images = [];
  bool isUploading = false;
  int _currentIndex = 0;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _images.add(File(pickedFile.path)));
      }
    } catch (e, stacktrace) {
      log("Error picking image: $e", error: e, stackTrace: stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เลือกรูปล้มเหลว: $e')),
      );
    }
  }

  Future<void> _uploadImagesAndSaveToFirestore() async {
   
  }

  Widget _buildImageTile(File? image, {int? index}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: image != null
                  ? FileImage(image)
                  : const AssetImage('assets/images/album.jpg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (image != null && index != null)
          Positioned(
            top: 5,
            right: 5,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _images.removeAt(index)),
              ),
            ),
          )
        else
          Positioned(
            bottom: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: isUploading ? null : _pickImage,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        title: Text('Albums', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _images.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 4 / 3,
                      ),
                      itemBuilder: (context, index) {
                        if (index < _images.length) {
                          return _buildImageTile(_images[index], index: index);
                        } else {
                          return _buildImageTile(null);
                        }
                      },
                    ),
                  ),
                  if (_images.isNotEmpty)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
                      ),
                      onPressed: isUploading ? null : _uploadImagesAndSaveToFirestore,
                      child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeHotel(userId: widget.userId)),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfileHotel(userId: widget.userId)),
            );
          }
        },
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Profile"),
        ],
      ),
    );
  }
}
