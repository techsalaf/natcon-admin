// To parse this JSON data, do
//
//     final couponinfo = couponinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Couponinfo couponinfoFromJson(String str) =>
    Couponinfo.fromJson(json.decode(str));

String couponinfoToJson(Couponinfo data) => json.encode(data.toJson());

class Couponinfo {
  List<Coupondatum> coupondata;
  String responseCode;
  String result;
  String responseMsg;

  Couponinfo({
    required this.coupondata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Couponinfo.fromJson(Map<String, dynamic> json) => Couponinfo(
        coupondata: List<Coupondatum>.from(
            json["coupondata"].map((x) => Coupondatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "coupondata": List<dynamic>.from(coupondata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Coupondatum {
  String id;
  String sponsoreId;
  String couponImg;
  String title;
  String couponCode;
  String subtitle;
  DateTime expireDate;
  String minAmt;
  String couponVal;
  String description;
  String status;

  Coupondatum({
    required this.id,
    required this.sponsoreId,
    required this.couponImg,
    required this.title,
    required this.couponCode,
    required this.subtitle,
    required this.expireDate,
    required this.minAmt,
    required this.couponVal,
    required this.description,
    required this.status,
  });

  factory Coupondatum.fromJson(Map<String, dynamic> json) => Coupondatum(
        id: json["id"],
        sponsoreId: json["sponsore_id"],
        couponImg: json["coupon_img"],
        title: json["title"],
        couponCode: json["coupon_code"],
        subtitle: json["subtitle"],
        expireDate: DateTime.parse(json["expire_date"]),
        minAmt: json["min_amt"],
        couponVal: json["coupon_val"],
        description: json["description"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sponsore_id": sponsoreId,
        "coupon_img": couponImg,
        "title": title,
        "coupon_code": couponCode,
        "subtitle": subtitle,
        "expire_date":
            "${expireDate.year.toString().padLeft(4, '0')}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.day.toString().padLeft(2, '0')}",
        "min_amt": minAmt,
        "coupon_val": couponVal,
        "description": description,
        "status": status,
      };
}
