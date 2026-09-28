// To parse this JSON data, do
//
//     final galleryInfo = galleryInfoFromJson(jsonString);

import 'dart:convert';

GalleryInfo galleryInfoFromJson(String str) =>
    GalleryInfo.fromJson(json.decode(str));

String galleryInfoToJson(GalleryInfo data) => json.encode(data.toJson());

class GalleryInfo {
  List<Gallerydatum> gallerydata;
  String responseCode;
  String result;
  String responseMsg;

  GalleryInfo({
    required this.gallerydata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory GalleryInfo.fromJson(Map<String, dynamic> json) => GalleryInfo(
        gallerydata: List<Gallerydatum>.from(
            json["gallerydata"].map((x) => Gallerydatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "gallerydata": List<dynamic>.from(gallerydata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Gallerydatum {
  String id;
  String eventTitle;
  String eventId;
  String image;
  String status;

  Gallerydatum({
    required this.id,
    required this.eventTitle,
    required this.eventId,
    required this.image,
    required this.status,
  });

  factory Gallerydatum.fromJson(Map<String, dynamic> json) => Gallerydatum(
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
