// To parse this JSON data, do
//
//     final userHotelGetResponse = userHotelGetResponseFromJson(jsonString);

import 'dart:convert';

List<UserHotelGetResponse> userHotelGetResponseFromJson(String str) => List<UserHotelGetResponse>.from(json.decode(str).map((x) => UserHotelGetResponse.fromJson(x)));

String userHotelGetResponseToJson(List<UserHotelGetResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserHotelGetResponse {
    int hotelId;
    String hotelName;
    String hotelName2;
    String hotelPhoto;
    String detal;
    int startingPrice;
    String phone;
    String contact;
    String location;
    double lat;
    double long;
    double? distance;
    


    UserHotelGetResponse({
        required this.hotelId,
        required this.hotelName,
        required this.hotelName2,
        required this.hotelPhoto,
        required this.detal,
        required this.startingPrice,
        required this.phone,
        required this.contact,
        required this.location,
        required this.lat,
        required this.long,
        this.distance,
    });

    factory UserHotelGetResponse.fromJson(Map<String, dynamic> json) => UserHotelGetResponse(
        hotelId: json["hotelID"],
        hotelName: json["hotelName"],
        hotelName2: json["hotelName2"],
        hotelPhoto: json["hotelPhoto"],
        detal: json["detal"],
        startingPrice: json["starting price"],
        phone: json["phone"],
        contact: json["contact"],
        location: json["location"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        distance: json['distance']?.toDouble(), 
    );

    Map<String, dynamic> toJson() => {
        "hotelID": hotelId,
        "hotelName": hotelName,
        "hotelName2": hotelName2,
        "hotelPhoto": hotelPhoto,
        "detal": detal,
        "starting price": startingPrice,
        "phone": phone,
        "contact": contact,
        "location": location,
        "lat": lat,
        "long": long,
    };
}
