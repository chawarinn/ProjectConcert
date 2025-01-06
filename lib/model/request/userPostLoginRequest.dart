// To parse this JSON data, do
//
//     final usersLoginPostRequest = usersLoginPostRequestFromJson(jsonString);

import 'dart:convert';

UsersLoginPostRequest usersLoginPostRequestFromJson(String str) => UsersLoginPostRequest.fromJson(json.decode(str));

String usersLoginPostRequestToJson(UsersLoginPostRequest data) => json.encode(data.toJson());

class UsersLoginPostRequest {
    String email;
    String password;

    UsersLoginPostRequest({
        required this.email,
        required this.password,
    });

    factory UsersLoginPostRequest.fromJson(Map<String, dynamic> json) => UsersLoginPostRequest(
        email: json["email"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
    };
}
