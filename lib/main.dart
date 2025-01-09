import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddHotel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/Location.dart';

import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/Member/DetailMember.dart';
import 'package:project_concert_closeiin/Page/Member/EditProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/Event.dart';
import 'package:project_concert_closeiin/Page/Member/EventDetailMember.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/hotel_search.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  //  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseFirestore.instance.settings = Settings(
  //   persistenceEnabled: true,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: LocationPage(),
      // home: AddHotel(userId: 4),
      home: AddRoom(hotelID: 2),
    );
  }
}
