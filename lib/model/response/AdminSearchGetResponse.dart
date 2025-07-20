import 'dart:convert';
class AdminSearchHGetResponse {
  int resID;
  String close;
  String open;
  double lat;
  double long;
  String contact;
  String resName;
  String type;
  String resPhoto;
  String location;
  int userId;

  AdminSearchHGetResponse({
    required this.resID,
    required this.close,
    required this.open,
    required this.lat,
    required this.long,
    required this.contact,
    required this.resName,
    required this.type,
    required this.resPhoto,
    required this.location,
    required this.userId,
  });

  factory AdminSearchHGetResponse.fromJson(Map<String, dynamic> json) {
    return AdminSearchHGetResponse(
      resID: json['resID'] ?? 0,
      close: json['close'] ?? '',
      open: json['open'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
      contact: json['contact'] ?? '',
      resName: json['resName'] ?? '',
      type: json['type'] ?? '',
      resPhoto: json['resPhoto'] ?? '',
      location: json['location'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }
}

