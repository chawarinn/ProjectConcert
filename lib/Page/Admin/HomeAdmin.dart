import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminArtist.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminEvent.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminProfile.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class HomeAdmin extends StatefulWidget {
  final int userId;
  const HomeAdmin({super.key, required this.userId});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _currentIndex = 0;
  bool _isLoading = false;
  late String url;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    }).catchError((err) {
      print(err);
    });

    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$API_ENDPOINT/AllUser');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final phone = (user['phone'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();

      return user['typeID'] != 5 &&
          (name.contains(query) ||
              email.contains(query) ||
              phone.contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'User',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeAdmin(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminEvent(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdminArtistPage(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdminHotelPage(userId: widget.userId)),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminRes(userId: widget.userId)),
              );
              break;
            case 5:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileAdmin(userId: widget.userId)),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.ticket), label: 'Event'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music), label: 'Artist'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotel'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.utensils), label: 'Restaurant'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Profile'),
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
                    setState(() {
                      searchQuery = value;
                    });
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
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator(color: Colors.black)))
              : filteredUsers.isEmpty
                  ? Expanded(
                    child: Center(
                        child: Text(
                          'No User',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  )
                  : Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return buildCard(
                            context,
                            filteredUsers[index],
                            _fetchAll,
                            widget.userId,
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

Widget buildCard(
  BuildContext context,
  dynamic user,
  Future<void> Function() onUpdated,
  int userId,
) {
  return Card(
    color: Colors.grey[200],
    margin: EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage(user['photo'] ?? 'https://via.placeholder.com/150')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(width: 6),
                        Icon(Icons.verified,
                            color: Colors.blueAccent, size: 20),
                      ],
                    ),
                    Text("ประเภทผู้ใช้ : ${user['typeName']}",
                        style: GoogleFonts.poppins(fontSize: 15)),
                    Text(
                        "เพศ : ${user['gender'] == 'Male' ? 'ชาย' : user['gender'] == 'Female' ? 'หญิง' : user['gender'] == 'Prefer not to say' ? 'ไม่ต้องการระบุ' : '-'}",
                        style: GoogleFonts.poppins(fontSize: 15)),
                    Text("เบอร์โทร : ${user['phone']}",
                        style: GoogleFonts.poppins(fontSize: 15)),
                    Text("อีเมลล์ :  ${user['email']}",
                        style: GoogleFonts.poppins(fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 35),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notification'),
                      content: Text('ต้องการลบข้อมูลผู้ใช้นี้หรือไม่?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child:
                              Text('No', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(
                          child:
                              CircularProgressIndicator(color: Colors.black)),
                    );

                    try {
                      final response = await http.delete(Uri.parse(
                        '$API_ENDPOINT/deleteAccount?userID=${user['userID']}',
                      ));
                      Navigator.pop(context);

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ลบเรียบร้อยแล้ว')),
                        );
                        await onUpdated();
                      } else {
                        throw Exception('ลบไม่สำเร็จ: ${response.body}');
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
