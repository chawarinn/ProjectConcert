import 'dart:convert';

List<UserRestaurantResponse> userRestaurantResponseFromJson(String str) =>
    List<UserRestaurantResponse>.from(
        json.decode(str).map((x) => UserRestaurantResponse.fromJson(x)));

String userRestaurantResponseToJson(List<UserRestaurantResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserRestaurantResponse {
  int resId;
  String resName;
  String resPhoto;
  int type;
  int open;
  int close;
  String location;
  double lat;
  double long;
  String? contact;
  double? distance;

  UserRestaurantResponse({
    required this.resId,
    required this.resName,
    required this.resPhoto,
    required this.type,
    required this.open,
    required this.close,
    required this.location,
    required this.lat,
    required this.long,
    this.contact,
    this.distance,
  });

  factory UserRestaurantResponse.fromJson(Map<String, dynamic> json) =>
      UserRestaurantResponse(
        resId: json["resId"],
        resName: json["resName"],
        resPhoto: json["resPhoto"],
        type: json["type"],
        open: json["open"],
        close: json["close"],
        location: json["location"],
        lat: (json["lat"] as num).toDouble(),
        long: (json["long"] as num).toDouble(),
        contact: json["contact"],
        distance: json["distance"] != null ? (json["distance"] as num).toDouble() : null,
      );

  Map<String, dynamic> toJson() => {
        "resId": resId,
        "resName": resName,
        "resPhoto": resPhoto,
        "type": type,
        "open": open,
        "close": close,
        "location": location,
        "lat": lat,
        "long": long,
        "contact": contact,
      };
}
