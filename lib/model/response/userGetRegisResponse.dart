// To parse this JSON data, do
//
//     final userGetAddressResponse = userGetAddressResponseFromJson(jsonString);

import 'dart:convert';

UserGetAddressResponse userGetAddressResponseFromJson(String str) => UserGetAddressResponse.fromJson(json.decode(str));

String userGetAddressResponseToJson(UserGetAddressResponse data) => json.encode(data.toJson());

class UserGetAddressResponse {
    String message;
    String imageUrl;
    int userId;

    UserGetAddressResponse({
        required this.message,
        required this.imageUrl,
        required this.userId,
    });

    factory UserGetAddressResponse.fromJson(Map<String, dynamic> json) => UserGetAddressResponse(
        message: json["message"],
        imageUrl: json["imageUrl"],
        userId: json["userID"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "imageUrl": imageUrl,
        "userID": userId,
    };
}
