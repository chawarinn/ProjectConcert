import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Event/AddArtist.dart';
import 'package:project_concert_closeiin/Page/Event/HomeEvent.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';

class SelectArtistPage extends StatefulWidget {
  final int userId;
  final List<String> existingArtistIds;

  const SelectArtistPage({
    super.key,
    required this.userId,
    required this.existingArtistIds,
  });

  @override
  State<SelectArtistPage> createState() => _SelectArtistPageState();
}

class _SelectArtistPageState extends State<SelectArtistPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<dynamic> allArtists = [];
  Set<String> selectedArtistIds = {};
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedArtistIds = widget.existingArtistIds.toSet();
    fetchArtists();
  }

  void toggleSelect(String artistId) {
    setState(() {
      if (selectedArtistIds.contains(artistId)) {
        selectedArtistIds.remove(artistId);
      } else {
        selectedArtistIds.add(artistId);
      }
    });
  }

  void searchArtists(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  Future<void> fetchArtists() async {
    try {
      final response = await http.get(Uri.parse('$API_ENDPOINT/artist'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allArtists = data;
          isLoading = false;
        });
      } else {
        log('Failed to load artists: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching artists: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredArtists = allArtists.where((artist) {
      final name = (artist['artistName'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery);
    }).toList();

    List<dynamic> selectedArtists = filteredArtists
        .where((artist) =>
            selectedArtistIds.contains(artist['artistID'].toString()))
        .toList();

    List<dynamic> unselectedArtists = filteredArtists
        .where((artist) =>
            !selectedArtistIds.contains(artist['artistID'].toString()))
        .toList();

    List<dynamic> artistsSorted = [...selectedArtists, ...unselectedArtists];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
          title: Text(
            'Artist',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context, selectedArtistIds.toList()),
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
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeEvent(userId : widget.userId)),
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => searchArtists(value),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 3 / 3.4,
                          ),
                          itemCount: artistsSorted.length,
                          itemBuilder: (context, index) {
                            final artist = artistsSorted[index];
                            final artistId = artist['artistID'].toString();
                            final isSelected =
                                selectedArtistIds.contains(artistId);

                            return GestureDetector(
                              onTap: () => toggleSelect(artistId),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.green, width: 3)
                                          : null,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        artist['artistPhoto'] ?? '',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    artist['artistName'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(201, 151, 187, 1),
                              ),
                              onPressed: () {
                                Navigator.pop(
                                    context, selectedArtistIds.toList());
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
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
