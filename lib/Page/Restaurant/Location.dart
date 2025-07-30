import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:project_concert_closeiin/Page/Home.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? currentLocation;
  late CameraPosition initPosition;
  Set<Marker> markers = {};
  final TextEditingController addressCtl = TextEditingController();
  List<Placemark> placemarks = [];
String? selectedAddress;
  LatLng? latLng; 

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;


    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // ตอนนี้สามารถเข้าถึงตำแหน่งได้แล้ว
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = LatLng(position.latitude, position.longitude);

    initPosition = CameraPosition(
      target: currentLocation!,
      zoom: 15,
    );

    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation!,
        infoWindow: const InfoWindow(title: 'Current Location'),
      ),
    );

    setState(() {});

    // Log the address
    placemarks = await placemarkFromCoordinates(
      currentLocation!.latitude,
      currentLocation!.longitude,
    );

    if (placemarks.isNotEmpty) {
      print('Address: ${placemarks[0].street}, ${placemarks[0].locality}');
      // เก็บค่าที่อยู่ในตัวแปร selectedAddress
      selectedAddress = '${placemarks[0].street}, ${placemarks[0].locality}';
      // หากต้องการใช้ selectedAddress ที่นี่ สามารถใช้งานได้เลย
      // เช่น: log(selectedAddress!);
      log(selectedAddress!);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(201, 151, 187, 1),
         title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            'Location',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: initPosition,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (LatLng point)  async {
                    setState(() {
                      latLng = point; 
                      markers.clear();
                      markers.add(
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: point,
                          infoWindow:
                              const InfoWindow(title: 'Selected Location'),
                        ),
                      );
                    });
                    placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
                    if (placemarks.isNotEmpty) {
                      selectedAddress = '${placemarks[0].street}, ${placemarks[0].locality}';
                      log(selectedAddress!);
                    }
                  },
                ),
                Positioned(
                  bottom: 25,
                  left: 100,
                  right: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (latLng != null ) {
                        Navigator.pop(context, {
                          'latitude': latLng!.latitude,
                          'longitude': latLng!.longitude,
                         'Address': selectedAddress ?? 'Unknown Address',
                        });
                        log(latLng.toString());
                        log('Latitude: ${latLng!.latitude}, Longitude: ${latLng!.longitude}');
                      } else {
                        // ส่งตำแหน่งปัจจุบันกลับไปหากไม่เลือกตำแหน่งใหม่
                        Navigator.pop(context, {
                          'latitude': currentLocation!.latitude,
                          'longitude': currentLocation!.longitude,
                          'Address': selectedAddress ?? 'Unknown Address',
                        });
                        log('Using default location: ${currentLocation.toString()}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(201, 151, 187, 1),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}