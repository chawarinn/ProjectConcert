// To parse this JSON data, do
//
//     final usersLoginPostResponse = usersLoginPostResponseFromJson(jsonString);

import 'dart:convert';

UsersLoginPostResponse usersLoginPostResponseFromJson(String str) => UsersLoginPostResponse.fromJson(json.decode(str));

String usersLoginPostResponseToJson(UsersLoginPostResponse data) => json.encode(data.toJson());

class UsersLoginPostResponse {
    String message;
    User user;

    UsersLoginPostResponse({
        required this.message,
        required this.user,
    });

    factory UsersLoginPostResponse.fromJson(Map<String, dynamic> json) => UsersLoginPostResponse(
        message: json["message"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "user": user.toJson(),
    };
}

class User {
    int userId;
    String name;
    String phone;
    String email;
    String password;
    String photo;
    int typeId;

    User({
        required this.userId,
        required this.name,
        required this.phone,
        required this.email,
        required this.password,
        required this.photo,
        required this.typeId,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["userID"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
        photo: json["photo"],
        typeId: json["typeID"],
    );

    Map<String, dynamic> toJson() => {
        "userID": userId,
        "name": name,
        "phone": phone,
        "email": email,
        "password": password,
        "photo": photo,
        "typeID": typeId,
    };
}
