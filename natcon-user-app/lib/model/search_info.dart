// To parse this JSON data, do
//
//     final searchInfo = searchInfoFromJson(jsonString);

import 'dart:convert';

SearchInfo searchInfoFromJson(String str) =>
    SearchInfo.fromJson(json.decode(str));

String searchInfoToJson(SearchInfo data) => json.encode(data.toJson());

class SearchInfo {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;

  SearchInfo({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
  });

  factory SearchInfo.fromJson(Map<String, dynamic> json) => SearchInfo(
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
