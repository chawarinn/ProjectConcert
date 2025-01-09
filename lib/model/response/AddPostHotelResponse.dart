// To parse this JSON data, do
//
//     final addHotelPostResponse = addHotelPostResponseFromJson(jsonString);

import 'dart:convert';

AddHotelPostResponse addHotelPostResponseFromJson(String str) => AddHotelPostResponse.fromJson(json.decode(str));

String addHotelPostResponseToJson(AddHotelPostResponse data) => json.encode(data.toJson());

class AddHotelPostResponse {
    String message;
    String imageUrl;
    int hotelId;

    AddHotelPostResponse({
        required this.message,
        required this.imageUrl,
        required this.hotelId,
    });

    factory AddHotelPostResponse.fromJson(Map<String, dynamic> json) => AddHotelPostResponse(
        message: json["message"],
        imageUrl: json["imageUrl"],
        hotelId: json["hotelID"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "imageUrl": imageUrl,
        "hotelID": hotelId,
    };
}
