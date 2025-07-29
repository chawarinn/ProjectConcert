
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminDetail.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
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
<<<<<<< HEAD
      // home: RestaurantSearch(userId: 3)
      // home: Event(userId: 3)
      // home: Homemember(userId: 3)
      // home: Eventdetailmember(userId: 3,eventID: 1,),
      // home: homeLogoPage()
      // home: HomeAdmin(userId: 7,)
      // home: AdminHotelPage(userId: 7,)
      // home: HotelSearch(userId: 3,)
      // home: LoginPage()
      // home: NotificationPage(userId: 3,) 
      // home: Admindetail(userId: 3),
      // home: DetailHotel(userId: 5, hotelID: 29,)
  //  home: Admindetail(userId: 6, hotelID: 11),
    // home: Homerestaurant(userId: 8)
    // home: HomeEvent(userId: 6)
    // home: AdminRes(userId: 5),
      home: Homemember(userId: 13)
    // home: HomeHotel(userId: 5)
=======
   
      home: HomeAdmin(userId: 5)
    //  home: Homemember(userId: 13),
>>>>>>> 152cb29591c62ac270192a65483d4fc098f3fabd
    );
  }
}
