// To parse this JSON data, do
//
//     final coverimageinfo = coverimageinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Coverimageinfo coverimageinfoFromJson(String str) =>
    Coverimageinfo.fromJson(json.decode(str));

String coverimageinfoToJson(Coverimageinfo data) => json.encode(data.toJson());

class Coverimageinfo {
  List<Extralist> extralist;
  String responseCode;
  String result;
  String responseMsg;

  Coverimageinfo({
    required this.extralist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Coverimageinfo.fromJson(Map<String, dynamic> json) => Coverimageinfo(
        extralist: List<Extralist>.from(
            json["extralist"].map((x) => Extralist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "extralist": List<dynamic>.from(extralist.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Extralist {
  String id;
  String eventTitle;
  String eventId;
  String image;
  String status;

  Extralist({
    required this.id,
    required this.eventTitle,
    required this.eventId,
    required this.image,
    required this.status,
  });

  factory Extralist.fromJson(Map<String, dynamic> json) => Extralist(
        id: json["id"],
        eventTitle: json["event_title"],
        eventId: json["event_id"],
        image: json["image"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "event_title": eventTitle,
        "event_id": eventId,
        "image": image,
        "status": status,
      };
}
