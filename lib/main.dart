
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminDetail.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Event/HomeEvent.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddHotel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/Location.dart';

import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/Member/DetailHotel.dart';
import 'package:project_concert_closeiin/Page/Member/EditProfileMember.dart';
import 'package:project_concert_closeiin/Page/Member/Event.dart';
import 'package:project_concert_closeiin/Page/Member/EventDetailMember.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/hotel_search.dart';
import 'package:project_concert_closeiin/Page/Hotel/AddRoom.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Member/AddRoomShare.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Restaurant/HomeRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/ProfileRestaurant.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
   
     home: Homemember(userId: 13)
    // home: HomeHotel(userId: 5),
    // home: homeLogoPage()
    // home: homeLogoPage(),

     
    
    );
  }
}
