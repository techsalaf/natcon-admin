// To parse this JSON data, do
//
//     final facilityInfo = facilityInfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

FacilityInfo facilityInfoFromJson(String str) =>
    FacilityInfo.fromJson(json.decode(str));

String facilityInfoToJson(FacilityInfo data) => json.encode(data.toJson());

class FacilityInfo {
  List<Facilitydatum> facilitydata;
  String responseCode;
  String result;
  String responseMsg;

  FacilityInfo({
    required this.facilitydata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory FacilityInfo.fromJson(Map<String, dynamic> json) => FacilityInfo(
        facilitydata: List<Facilitydatum>.from(
            json["Facilitydata"].map((x) => Facilitydatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Facilitydata": List<dynamic>.from(facilitydata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Facilitydatum {
  String id;
  String title;
  String img;
  String status;

  Facilitydatum({
    required this.id,
    required this.title,
    required this.img,
    required this.status,
  });

  factory Facilitydatum.fromJson(Map<String, dynamic> json) => Facilitydatum(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "status": status,
      };
}
