// To parse this JSON data, do
//
//     final fevInfo = fevInfoFromJson(jsonString);

import 'dart:convert';

FevInfo fevInfoFromJson(String str) => FevInfo.fromJson(json.decode(str));

String fevInfoToJson(FevInfo data) => json.encode(data.toJson());

class FevInfo {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;

  FevInfo({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
  });

  factory FevInfo.fromJson(Map<String, dynamic> json) => FevInfo(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventSdate: json["event_sdate"],
        eventPlaceName: json["event_place_name"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_sdate": eventSdate,
        "event_place_name": eventPlaceName,
      };
}
