// To parse this JSON data, do
//
//     final categoryinfo = categoryinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Categoryinfo categoryinfoFromJson(String str) =>
    Categoryinfo.fromJson(json.decode(str));

String categoryinfoToJson(Categoryinfo data) => json.encode(data.toJson());

class Categoryinfo {
  List<Categorydatum> categorydata;
  String responseCode;
  String result;
  String responseMsg;

  Categoryinfo({
    required this.categorydata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Categoryinfo.fromJson(Map<String, dynamic> json) => Categoryinfo(
        categorydata: List<Categorydatum>.from(
            json["Categorydata"].map((x) => Categorydatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Categorydata": List<dynamic>.from(categorydata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Categorydatum {
  String id;
  String title;
  String img;
  String status;
  String cover;

  Categorydatum({
    required this.id,
    required this.title,
    required this.img,
    required this.status,
    required this.cover,
  });

  factory Categorydatum.fromJson(Map<String, dynamic> json) => Categorydatum(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        status: json["status"],
        cover: json["cover"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "status": status,
        "cover": cover,
      };
}
