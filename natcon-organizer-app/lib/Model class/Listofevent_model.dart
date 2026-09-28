// To parse this JSON data, do
//
//     final listofeventinfo = listofeventinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Listofeventinfo listofeventinfoFromJson(String str) =>
    Listofeventinfo.fromJson(json.decode(str));

String listofeventinfoToJson(Listofeventinfo data) =>
    json.encode(data.toJson());

class Listofeventinfo {
  String eventId;
  String eventTitle;
  String eventCatId;
  String eventCatName;
  String eventCoverImg;
  String eventImage;
  String eventStatus;
  DateTime eventStartDate;
  String eventStartTime;
  String eventEndTime;
  String eventAddress;
  String eventDescription;
  String eventDisclaimer;
  String eventLatitude;
  String eventLongtitude;
  String eventProgress;
  String eventPlaceName;
  String eventFacilityId;
  String? eventRestictId;
  String eventTags;
  String eventVurls;

  Listofeventinfo({
    required this.eventId,
    required this.eventTitle,
    required this.eventCatId,
    required this.eventCatName,
    required this.eventCoverImg,
    required this.eventImage,
    required this.eventStatus,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventAddress,
    required this.eventDescription,
    required this.eventDisclaimer,
    required this.eventLatitude,
    required this.eventLongtitude,
    required this.eventProgress,
    required this.eventPlaceName,
    required this.eventFacilityId,
     this.eventRestictId,
    required this.eventTags,
    required this.eventVurls,
  });

  factory Listofeventinfo.fromJson(Map<String, dynamic> json) =>
      Listofeventinfo(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventCatId: json["event_cat_id"],
        eventCatName: json["event_cat_name"],
        eventCoverImg: json["event_cover_img"],
        eventImage: json["event_image"],
        eventStatus: json["event_status"],
        eventStartDate: DateTime.parse(json["event_start_date"]),
        eventStartTime: json["event_start_time"],
        eventEndTime: json["event_end_time"],
        eventAddress: json["event_address"],
        eventDescription: json["event_description"],
        eventDisclaimer: json["event_disclaimer"],
        eventLatitude: json["event_latitude"],
        eventLongtitude: json["event_longtitude"],
        eventProgress: json["event_progress"],
        eventPlaceName: json["event_place_name"],
        eventFacilityId: json["event_facility_id"].toString(),
        eventRestictId: json["event_restict_id"] ?? null,
        eventTags: json["event_tags"],
        eventVurls: json["event_vurls"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_cat_id": eventCatId,
        "event_cat_name": eventCatName,
        "event_cover_img": eventCoverImg,
        "event_image": eventImage,
        "event_status": eventStatus,
        "event_start_date": "${eventStartDate.year.toString().padLeft(4, '0')}-${eventStartDate.month.toString().padLeft(2, '0')}-${eventStartDate.day.toString().padLeft(2, '0')}",
        "event_start_time": eventStartTime,
        "event_end_time": eventEndTime,
        "event_address": eventAddress,
        "event_description": eventDescription,
        "event_disclaimer": eventDisclaimer,
        "event_latitude": eventLatitude,
        "event_longtitude": eventLongtitude,
        "event_progress": eventProgress,
        "event_place_name": eventPlaceName,
        "event_facility_id": eventFacilityId,
        "event_restict_id": eventRestictId,
        "event_tags": eventTags,
        "event_vurls": eventVurls,
      };
}
