// To parse this JSON data, do
//
//     final dynamicPageData = dynamicPageDataFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

DynamicPageData dynamicPageDataFromJson(String str) =>
    DynamicPageData.fromJson(json.decode(str));

String dynamicPageDataToJson(DynamicPageData data) =>
    json.encode(data.toJson());

class DynamicPageData {
  List<Pagelist> pagelist;
  String responseCode;
  String result;
  String responseMsg;

  DynamicPageData({
    required this.pagelist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory DynamicPageData.fromJson(Map<String, dynamic> json) =>
      DynamicPageData(
        pagelist: List<Pagelist>.from(
            json["pagelist"].map((x) => Pagelist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "pagelist": List<dynamic>.from(pagelist.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Pagelist {
  String title;
  String description;

  Pagelist({
    required this.title,
    required this.description,
  });

  factory Pagelist.fromJson(Map<String, dynamic> json) => Pagelist(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}
