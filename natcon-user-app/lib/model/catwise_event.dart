// To parse this JSON data, do
//
//     final catWiseInfo = catWiseInfoFromJson(jsonString);

import 'dart:convert';

CatWiseInfo catWiseInfoFromJson(String str) =>
    CatWiseInfo.fromJson(json.decode(str));

String catWiseInfoToJson(CatWiseInfo data) => json.encode(data.toJson());

class CatWiseInfo {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;

  CatWiseInfo({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
  });

  factory CatWiseInfo.fromJson(Map<String, dynamic> json) => CatWiseInfo(
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
