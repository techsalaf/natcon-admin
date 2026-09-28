// To parse this JSON data, do
//
//     final restrictioninfo = restrictioninfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Restrictioninfo restrictioninfoFromJson(String str) =>
    Restrictioninfo.fromJson(json.decode(str));

String restrictioninfoToJson(Restrictioninfo data) =>
    json.encode(data.toJson());

class Restrictioninfo {
  List<Restrictiondatum> restrictiondata;
  String responseCode;
  String result;
  String responseMsg;

  Restrictioninfo({
    required this.restrictiondata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Restrictioninfo.fromJson(Map<String, dynamic> json) =>
      Restrictioninfo(
        restrictiondata: List<Restrictiondatum>.from(
            json["Restrictiondata"].map((x) => Restrictiondatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "Restrictiondata":
            List<dynamic>.from(restrictiondata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Restrictiondatum {
  String id;
  String title;
  String img;
  String status;

  Restrictiondatum({
    required this.id,
    required this.title,
    required this.img,
    required this.status,
  });

  factory Restrictiondatum.fromJson(Map<String, dynamic> json) =>
      Restrictiondatum(
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
