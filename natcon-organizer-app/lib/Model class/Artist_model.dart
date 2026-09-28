// To parse this JSON data, do
//
//     final artistinfo = artistinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Artistinfo artistinfoFromJson(String str) =>
    Artistinfo.fromJson(json.decode(str));

String artistinfoToJson(Artistinfo data) => json.encode(data.toJson());

class Artistinfo {
  List<Artistdatum> artistdata;
  String responseCode;
  String result;
  String responseMsg;

  Artistinfo({
    required this.artistdata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Artistinfo.fromJson(Map<String, dynamic> json) => Artistinfo(
        artistdata: List<Artistdatum>.from(
            json["Artistdata"].map((x) => Artistdatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Artistdata": List<dynamic>.from(artistdata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Artistdatum {
  String id;
  String eventTitle;
  String eventId;
  String image;
  String title;
  String arole;
  String status;

  Artistdatum({
    required this.id,
    required this.eventTitle,
    required this.eventId,
    required this.image,
    required this.title,
    required this.arole,
    required this.status,
  });

  factory Artistdatum.fromJson(Map<String, dynamic> json) => Artistdatum(
        id: json["id"],
        eventTitle: json["event_title"],
        eventId: json["event_id"],
        image: json["image"],
        title: json["title"],
        arole: json["arole"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "event_title": eventTitle,
        "event_id": eventId,
        "image": image,
        "title": title,
        "arole": arole,
        "status": status,
      };
}
