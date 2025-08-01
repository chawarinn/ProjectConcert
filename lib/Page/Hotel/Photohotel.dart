import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'HomeHotel.dart';
import 'dart:io';
import 'Profile.dart';
import 'dart:convert';

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
  bool _isDeleting = false;
  int _currentIndex = 0;
  late Future<List<String>> _futurePhotos;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _futurePhotos = _fetchHotelPhotos();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _initialLoading = false;
      });
    });
  }

  Future<void> _pickImage() async {
    if (_images.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สามารถเพิ่มรูปได้ครั้งละไม่เกิน 20 รูป')),
      );
      return;
    }
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _images.add(File(pickedFile.path)));
      }
    } catch (e, stacktrace) {
      log("Error picking image: $e", error: e, stackTrace: stacktrace);
      
    }
  }

  Future<List<String>> _fetchHotelPhotos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('photo')
        .where('hotelID', isEqualTo: widget.hotelID)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final List<dynamic> rawUrls = data['photo'] ?? [];
      return rawUrls.cast<String>();
    } else {
      return [];
    }
  }

  Future<void> _uploadImagesAndSaveToFirestore() async {
    setState(() {
      isUploading = true;
    });

    try {
      List<String> downloadUrls = [];

      for (var image in _images) {
        String fileName = path.basename(image.path);
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$API_ENDPOINT/photo'),
        );
        request.files
            .add(await http.MultipartFile.fromPath('file', image.path));
        var response = await request.send();
        final responseData = await response.stream.bytesToString();
        print("Server response: $responseData");

        if (response.statusCode == 200) {
          final data = jsonDecode(responseData);
          final urlList = List<String>.from(data['urls']);
          downloadUrls.addAll(urlList);
        } else {
          throw Exception("ไม่สามารถอัปโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง");
        }
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference photosRef = firestore.collection('photo');

      DocumentReference? existingDoc;

      QuerySnapshot snapshot =
          await photosRef.where('hotelID', isEqualTo: widget.hotelID).get();
      if (snapshot.docs.isNotEmpty) {
        // ถ้ามีให้ update
        existingDoc = snapshot.docs.first.reference;
        await existingDoc.update({
          'photo': FieldValue.arrayUnion(downloadUrls),
        });
      } else {
        await photosRef.add({
          'hotelID': widget.hotelID,
          'userID': widget.userId,
          'photo': downloadUrls,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกรูปสำเร็จ')),
      );
      setState(() {
        _images.clear();
        _futurePhotos = _fetchHotelPhotos();
      });
    } catch (e) {
       showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('Notification'),
      content: Text('อินเทอร์เน็ตขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  },
);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _showDeleteDialog(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: const Text('คุณแน่ใจว่าต้องการลบรูปนี้หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePhoto(photoUrl);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhoto(String photoUrl) async {
    setState(() => _isDeleting = true);
    try {
      final ref = FirebaseStorage.instance.refFromURL(photoUrl);
      await ref.delete();

      final snapshot = await FirebaseFirestore.instance
          .collection('photo')
          .where('hotelID', isEqualTo: widget.hotelID)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'photo': FieldValue.arrayRemove([photoUrl]),
        });
      }

      setState(() {
        _futurePhotos = _fetchHotelPhotos();
      });
    } catch (e, stacktrace) {
      log('เกิดข้อผิดพลาดในการลบรูป', error: e, stackTrace: stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบรูปไม่สำเร็จ: $e')),
      );
    } finally {
      setState(() => _isDeleting = false); // หยุดโหลด
    }
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
                  : const AssetImage('assets/images/album.jpg')
                      as ImageProvider,
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
        else if (_images.length < 20)
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

  Widget _buildMainContent() {
    if (_initialLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          if (_images.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'สามารถเพิ่มรูปพร้อมกันได้สูงสุด 20 รูป',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          if (_images.isNotEmpty)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
                ),
                onPressed: isUploading ? null : _uploadImagesAndSaveToFirestore,
                child: const Text('Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          if (_images.isNotEmpty && _images.length < 20)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'สามารถเพิ่มรูปได้อีก ${20 - _images.length} รูป',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'My Albums',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: FutureBuilder<List<String>>(
              future: _futurePhotos,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(child: const Text('ยังไม่มีรูปที่อัปโหลด')),
                  );
                }

                final photoUrls = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: photoUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 4 / 3,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(photoUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 25),
                            onPressed: () {
                              _showDeleteDialog(context, photoUrls[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Albums',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('คุณต้องการออกจากระบบ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No',
                          style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          if (isUploading || _isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeHotel(userId: widget.userId)),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileHotel(userId: widget.userId)),
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
