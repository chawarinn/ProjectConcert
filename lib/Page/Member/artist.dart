import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class ArtistPage extends StatefulWidget {
  final int userId;
  const ArtistPage({super.key, required this.userId});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  int _currentIndex = 1;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> artistList = [];
  Set<int> favoriteArtistIds = {};
  bool isLoading = true;
  String url = '';

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

  Future<void> fetchArtists() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/artist'));
      final favResponse =
          await http.get(Uri.parse('$API_ENDPOINT/favArtist/${widget.userId}'));

      if (response.statusCode == 200 && favResponse.statusCode == 200) {
        final decoded = json.decode(response.body);
        final favDecoded = json.decode(favResponse.body);

        setState(() {
          artistList = decoded;
          favoriteArtistIds = favDecoded.map<int>((item) => item['artistID'] as int).toSet();
          isLoading = false;
        });

        print('Favorite artist IDs: $favoriteArtistIds');
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
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
      final response = await http.get(Uri.parse('$API_ENDPOINT/search/artist?query=$query'));

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

  Future<void> addToFavorites(int artistId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_ENDPOINT/addArtist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': widget.userId,
          'artistID': artistId,
        }),
      );

      if (response.statusCode == 201) {
  setState(() {
    favoriteArtistIds.add(artistId);
  });

  // ดึงข้อมูล artist เต็มจาก artistList
  final artist = artistList.firstWhere((a) => a['artistID'] == artistId);

  // เพิ่มลง Firebase
  final dbRef = FirebaseDatabase.instance.ref('roomshare_requests');
  final snapshot = await dbRef.get();

  if (snapshot.exists) {
    Map<dynamic, dynamic> requests = snapshot.value as Map;

    for (var entry in requests.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'lastID') continue;
      if (value['userReqID'] == widget.userId) {
        final requestRef = dbRef.child('$key/favoriteArtists');
        final DataSnapshot favSnapshot = await requestRef.get();

        Map<String, dynamic> newArtist = {
          'artistName': artist['artistName'],
          'artistPhoto': artist['artistPhoto'],
        };

        if (favSnapshot.exists) {
          await requestRef.child(artistId.toString()).set(newArtist);
        } else {
          await requestRef.set({
            artistId.toString(): newArtist,
          });
        }
      }
    }
  }
}

    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

Future<void> removeFromFavorites(int artistId) async {
  try {
    final response = await http.post(
      Uri.parse('$API_ENDPOINT/removeArtist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userID': widget.userId,
        'artistID': artistId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        favoriteArtistIds.remove(artistId);
      });

      // ลบออกจาก Firebase
      final dbRef = FirebaseDatabase.instance.ref('roomshare_requests');
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> requests = snapshot.value as Map;

        for (var entry in requests.entries) {
          final key = entry.key;
          final value = entry.value;

          if (key == 'lastID') continue;
          if (value['userReqID'] == widget.userId) {
            final artistPath = '$key/favoriteArtists/${artistId.toString()}';
            await dbRef.child(artistPath).remove();
          }
        }
      }
    } else {
      print('Failed to remove artist from favorites');
    }
  } catch (e) {
    print('Error removing from favorites: $e');
  }
}


  @override
  void dispose() {
    searchController.dispose();
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

    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: Text(
          "Artist",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20
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
                      child: const Text('No',style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => homeLogoPage()),
                        );
                      },
                      child: const Text('Yes',style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 200,
          height: 40,
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              searchQuery = value;
              searchArtists(searchQuery);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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

    if (isLoading)
      const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      )
    else if (artistList.isEmpty)
      Expanded(
        child: Center(
          child: Text('No artist found'),
        ),
      )
    else
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (favoriteArtists.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Favorite Artist",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

            if (favoriteArtists.isNotEmpty)
              ...favoriteArtists.map((artist) => artistCard(artist, true)),

            const SizedBox(height: 16),

            if (otherArtists.isNotEmpty) ...[
              Text(
                "Artist",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ...otherArtists.map((artist) => artistCard(artist, false)),
            ]
          ],
        ),
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
                    builder: (context) =>
                        Homemember(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ArtistPage(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NotificationPage(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileMember(
                          userId: widget.userId,
                        )),
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
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.heartPulse),
            label: 'Favorite Artist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget artistCard(dynamic artist, bool isFavorite) {
    return Card(
      color: Color.fromRGBO(228, 203, 221, 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color.fromARGB(255, 182, 75, 68) : null,
              ),
              onPressed: () {
                if (isFavorite) {
                  removeFromFavorites(artist['artistID']);
                } else {
                  addToFavorites(artist['artistID']);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
