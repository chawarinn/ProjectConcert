import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminArtist.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminEvent.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminHotel.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminProfile.dart';
import 'package:project_concert_closeiin/Page/Admin/AdminRes.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Event/AddArtist.dart';
import 'package:project_concert_closeiin/Page/Event/Profile.dart';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:project_concert_closeiin/Page/Event/HomeEvent.dart';
import 'package:project_concert_closeiin/Page/Hotel/Profile.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/Notification.dart';
import 'package:project_concert_closeiin/Page/Member/artist.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Member/ProfileMember.dart';
import 'package:project_concert_closeiin/Page/Restaurant/HomeRestaurant.dart';
import 'package:project_concert_closeiin/Page/Restaurant/ProfileRestaurant.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:project_concert_closeiin/Page/User/artistUser.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userId = box.read('userId');
    final typeId = box.read('typeId');
    final lastVisitedPage = box.read('lastVisitedPage');
    final isSkipped = box.read('isSkippedLogin') ?? false;

    Widget startPage;

    if (userId != null && typeId != null) {
      switch (typeId) {
        case 1:
          switch (lastVisitedPage) {
            case 'artist':
              startPage = ArtistPage(userId: userId);
              break;
            case 'notification':
              startPage = NotificationPage(userId: userId);
              break;
            case 'profile':
              startPage = ProfileMember(userId: userId);
              break;
            default:
              startPage = Homemember(userId: userId);
          }
          break;
        case 2:
          switch (lastVisitedPage) {
            case 'profileHotel':
              startPage = ProfileHotel(userId: userId);
              break;
            default:
              startPage = HomeHotel(userId: userId);
          }
          break;
        case 3:
          switch (lastVisitedPage) {
            case 'profileRes':
              startPage = ProfileRestaurant(userId: userId);
              break;
            default:
              startPage = Homerestaurant(userId: userId);
          }
          break;
        case 4:
          switch (lastVisitedPage) {
            case 'eventartist':
              startPage = AddArtistPage(userId: userId);
              break;
            case 'profileEvent':
              startPage = ProfileEvent(userId: userId);
              break;
            default:
              startPage = HomeEvent(userId: userId);
          }
          break;
        case 5:
          switch (lastVisitedPage) {
            case 'homeAdmin':
              startPage = HomeAdmin(userId: userId);
              break;
            case 'event':
              startPage = AdminEvent(userId: userId);
              break;
            case 'addartist':
              startPage = AdminArtistPage(userId: userId);
              break;
            case 'hotel':
              startPage = AdminHotelPage(userId: userId);
              break;
            case 'res':
              startPage = AdminRes(userId: userId);
              break;
            case 'profileAdmin':
              startPage = ProfileAdmin(userId: userId);
              break;
            default:
              startPage = HomeAdmin(userId: userId);
          }
          break;
        default:
          startPage = homeLogoPage();
      }
    } else if (isSkipped && userId == null) {
      switch (lastVisitedPage) {
            case 'artistuser':
              startPage = ArtistUserPage();
              break;
            default:
              startPage = HomeUser();
          } 
    } else {
      startPage = homeLogoPage();
    }

    return GetMaterialApp(
      title: 'Concert Closeiin',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: startPage,
    );
  }
}
