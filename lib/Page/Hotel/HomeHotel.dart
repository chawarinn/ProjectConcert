import 'package:flutter/material.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddHotel.dart';

class HomeHotel extends StatefulWidget {
  int userId;
   HomeHotel({super.key,  required this.userId});

  @override
  State<HomeHotel> createState() => _HomeHotelState();
}

class _HomeHotelState extends State<HomeHotel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
                            width: 200,
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddHotel(userId: widget.userId),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 190, 150, 198),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 30,color: Colors.white),
                              ),
                            ),
                          ),
      ),
    );
  }
}