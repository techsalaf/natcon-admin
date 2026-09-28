// To parse this JSON data, do
//
//     final mapInfo = mapInfoFromJson(jsonString);

import 'dart:convert';

MapInfo mapInfoFromJson(String str) => MapInfo.fromJson(json.decode(str));

String mapInfoToJson(MapInfo data) => json.encode(data.toJson());

class MapInfo {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;
  String eventLatitude;
  String eventLongtitude;

  MapInfo({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
    required this.eventLatitude,
    required this.eventLongtitude,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) => MapInfo(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventSdate: json["event_sdate"],
        eventPlaceName: json["event_place_name"],
        eventLatitude: json["event_latitude"],
        eventLongtitude: json["event_longtitude"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_sdate": eventSdate,
        "event_place_name": eventPlaceName,
        "event_latitude": eventLatitude,
        "event_longtitude": eventLongtitude,
      };
}
