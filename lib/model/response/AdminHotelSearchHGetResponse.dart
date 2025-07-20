import 'dart:convert';
class AdminHotelSearchHGetResponse {
  int hotelId;
  String hotelName;
  String hotelName2;
  String hotelPhoto;
  String detail;
  double lat;
  double long;
  String phone;
  String contact;
  int startingPrice;
  String location;
  int userId;
  int totalPiont;

  AdminHotelSearchHGetResponse({
    required this.hotelId,
    required this.hotelName,
    required this.hotelName2,
    required this.hotelPhoto,
    required this.detail,
    required this.lat,
    required this.long,
    required this.phone,
    required this.contact,
    required this.startingPrice,
    required this.location,
    required this.userId,
    required this.totalPiont,
  });

  factory AdminHotelSearchHGetResponse.fromJson(Map<String, dynamic> json) {
    return AdminHotelSearchHGetResponse(
      hotelId: json['hotelId'],
      hotelName: json['hotelName'],
      hotelName2: json['hotelName2'],
      hotelPhoto: json['hotelPhoto'],
      detail: json['detail'],
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
      phone: json['phone'],
      contact: json['contact'],
      startingPrice: json['startingPrice'],
      location: json['location'],
      userId: json['userId'],
      totalPiont: json['totalPiont'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'hotelName2': hotelName2,
      'hotelPhoto': hotelPhoto,
      'detail': detail,
      'lat': lat,
      'long': long,
      'phone': phone,
      'contact': contact,
      'startingPrice': startingPrice,
      'location': location,
      'userId': userId,
      'totalPiont': totalPiont,
    };
  }
}

