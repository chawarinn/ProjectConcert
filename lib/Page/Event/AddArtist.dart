import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_concert_closeiin/Page/Event/HomeEvent.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class AddArtistPage extends StatefulWidget {
  final int userId;
  AddArtistPage({super.key, required this.userId});
  @override
  _AddArtistPageState createState() => _AddArtistPageState();
}

class _AddArtistPageState extends State<AddArtistPage> {
  int _currentIndex = 1;
  TextEditingController searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String searchQuery = '';
  String searchQuery2 = '';
  List<dynamic> artistList = [];
  Set<int> favoriteArtistIds = {};
  bool isLoading = true;
  String url = '';
  File? _image;
  String? _photo;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (config) {
        url = config['apiEndpoint'];
        fetchArtists();
      },
    ).catchError((err) {
      log(err.toString());
      fetchArtists();
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  Future<void> fetchArtists() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/artist'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          artistList = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log('Error fetching artists: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchArtists(String query) async {
    if (query.isEmpty) {
      fetchArtists();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$API_ENDPOINT/search/artist?query=$query'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          artistList = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to search artists');
      }
    } catch (e) {
      log('Search artists error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveArtist() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showAlertDialog(context, "กรุณากรอกชื่อศิลปิน");
      return;
    }
      if (_image == null) {
  _showAlertDialog(context, "กรุณาเลือกรูปศิลปิน");
  return;
}
 bool isValidText(String text) {
      return RegExp(r'[a-zA-Zก-ฮ0-9]').hasMatch(text);
    }

    if (!isValidText(_nameController.text) ) {
      _showAlertDialog(context, "กรุณากรอกชื่อศิลปินให้ถูกต้อง");
      return;
    }

    final isDuplicate = artistList.any((artist) =>
        artist['artistName'].toString().toLowerCase() == name.toLowerCase());

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ศิลปินนี้มีอยู่แล้ว')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    final uri = Uri.parse('$API_ENDPOINT/add');
    final request = http.MultipartRequest('POST', uri);

    request.fields['artistName'] = _nameController.text;

    if (_image != null) {
      final fileStream = http.ByteStream(_image!.openRead());
      final length = await _image!.length();
      request.files.add(http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: _image!.path.split('/').last,
      ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showAlertDialog(
          context,
          'เพิ่มศิลปินสำเร็จ',
          onOkPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AddArtistPage(userId: widget.userId),
              ),
              (route) => false,
            );
          },
        );
      } else {
        _showAlertDialog(
            context, "เพิ่มข้อมูลไม่สำเร็จ (${response.statusCode})");
      }
    } catch (e) {
      Navigator.pop(context);
      _showAlertDialog(context, 'เกิดข้อผิดพลาด: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String message,
      {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteArtists = artistList
        .where((a) => favoriteArtistIds.contains(a['artistID']))
        .toList();
    final otherArtists = artistList
        .where((a) => !favoriteArtistIds.contains(a['artistID']))
        .toList();
    final List filteredArtists = artistList
        .where((artist) => artist['artistName']
            .toString()
            .toLowerCase()
            .contains(searchQuery2.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        automaticallyImplyLeading: false,
        title: Text(
          "Artist",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('คุณต้องการออกจากระบบ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const homeLogoPage()));
                        },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeEvent(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AddArtistPage(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileEvent(userId: widget.userId)),
              );
              break;
          }
        },
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Artist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchQuery = value;
                    searchArtists(searchQuery);
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (searchQuery.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: _image != null
                                              ? FileImage(_image!)
                                              : (_photo != null &&
                                                      _photo!.isNotEmpty
                                                  ? NetworkImage(_photo!)
                                                  : AssetImage(
                                                          'assets/images/album.jpg')
                                                      as ImageProvider),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              232, 234, 237, 1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(_image != null
                                              ? Icons.edit
                                              : Icons.add),
                                          color: Colors.black,
                                          onPressed: _pickImage,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: const TextSpan(
                                  text: 'Artist Name ',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              TextField(
                                controller: _nameController,
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery2 = value.trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(217, 217, 217, 1),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              if (searchQuery2.isNotEmpty &&
                                  filteredArtists.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'May be repeated with:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                ...filteredArtists.map(
                                  (artist) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(artist['artistPhoto']),
                                    ),
                                    title: Text(artist['artistName']),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 15),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _saveArtist,
                                  child: const Text('Save',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(201, 151, 187, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (artistList.isEmpty)
                          Center(child: Text('No artist found'))
                        else ...[
                          Text(
                            "Artist",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          ...otherArtists
                              .map((artist) => artistCard(artist, false)),
                        ],
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget artistCard(dynamic artist, bool isFavorite) {
    return Card(
      color: Color.fromRGBO(228, 203, 221, 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                artist['artistPhoto'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 70),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                artist['artistName'],
                style: const TextStyle(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Notification'),
                    content: Text('ต้องการลบศิลปินนี้หรือไม่?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child:
                            Text('No', style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child:
                            Text('Yes', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(child: CircularProgressIndicator(color: Colors.black)),
                  );

                  try {
                    final response = await http.delete(Uri.parse(
                      '$API_ENDPOINT/deleteartist?artistID=${artist['artistID']}',
                    ));

                    Navigator.pop(context);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                      );

                      setState(() {
                        artistList.removeWhere(
                            (a) => a['artistID'] == artist['artistID']);
                      });
                    } else {
                      final decoded = json.decode(response.body);
                      final errorMessage =
                          decoded['message'] ?? 'เกิดข้อผิดพลาดไม่ทราบสาเหตุ';

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Notification'),
                          content: Text(errorMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('ข้อผิดพลาด'),
                        content: Text('เกิดข้อผิดพลาด: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
