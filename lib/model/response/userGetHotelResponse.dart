import 'dart:convert';

List<UserHotelGetResponse> userHotelGetResponseFromJson(String str) =>
    List<UserHotelGetResponse>.from(json.decode(str).map((x) => UserHotelGetResponse.fromJson(x)));

String userHotelGetResponseToJson(List<UserHotelGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserHotelGetResponse {
  int hotelId;
  String hotelName;
  String hotelName2;
  String hotelPhoto;
  String detail;
  int startingPrice;
  String phone;
  String contact;
  String location;
  double lat;
  double long;
  double? distance;
  int totalPiont;

  UserHotelGetResponse({
    required this.hotelId,
    required this.hotelName,
    required this.hotelName2,
    required this.hotelPhoto,
    required this.detail,
    required this.startingPrice,
    required this.phone,
    required this.contact,
    required this.location,
    required this.lat,
    required this.long,
    this.distance,
    required this.totalPiont,
  });

  factory UserHotelGetResponse.fromJson(Map<String, dynamic> json) => UserHotelGetResponse(
        hotelId: json["hotelID"],
        hotelName: json["hotelName"],
        hotelName2: json["hotelName2"],
        hotelPhoto: json["hotelPhoto"],
        detail: json["detail"],
        startingPrice: json["startingPrice"],
        phone: json["phone"],
        contact: json["contact"],
        location: json["location"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        distance: json["distance"]?.toDouble(),
        totalPiont: json["totalPiont"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "hotelID": hotelId,
        "hotelName": hotelName,
        "hotelName2": hotelName2,
        "hotelPhoto": hotelPhoto,
        "detail": detail,
        "startingPrice": startingPrice,
        "phone": phone,
        "contact": contact,
        "location": location,
        "lat": lat,
        "long": long,
        "distance": distance,
        "totalPiont": totalPiont,
      };
}
