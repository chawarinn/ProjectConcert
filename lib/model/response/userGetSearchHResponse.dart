import 'dart:convert';

List<UserSearchHGetResponse> userSearchHGetResponseFromJson(String str) =>
    List<UserSearchHGetResponse>.from(
        json.decode(str).map((x) => UserSearchHGetResponse.fromJson(x)));

String userSearchHGetResponseToJson(List<UserSearchHGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSearchHGetResponse {
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

  UserSearchHGetResponse({
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
  });

  factory UserSearchHGetResponse.fromJson(Map<String, dynamic> json) =>
      UserSearchHGetResponse(
        hotelId: json["hotelID"],                         
        hotelName: json["hotelName"],                        
        hotelName2: json["hotelName2"],                      
        hotelPhoto: json["hotelPhoto"],                     
        detail: json["detail"],                                
        startingPrice: json["startingPrice"],              
        phone: json["phone"],                               
        contact: json["contact"],                            
        location: json["location"],                         
        lat: json["lat"]?.toDouble() ?? 0.0,                 
        long: json["long"]?.toDouble() ?? 0.0,               
        distance: json["distance"]?.toDouble(),             
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
      };
}
