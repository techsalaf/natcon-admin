// To parse this JSON data, do
//
//     final couponInfo = couponInfoFromJson(jsonString);

import 'dart:convert';

CouponInfo couponInfoFromJson(String str) =>
    CouponInfo.fromJson(json.decode(str));

String couponInfoToJson(CouponInfo data) => json.encode(data.toJson());

class CouponInfo {
  String id;
  String cImg;
  DateTime expireDate;
  String description;
  String couponVal;
  String couponCode;
  String couponTitle;
  String couponSubtitle;
  String minAmt;

  CouponInfo({
    required this.id,
    required this.cImg,
    required this.expireDate,
    required this.description,
    required this.couponVal,
    required this.couponCode,
    required this.couponTitle,
    required this.couponSubtitle,
    required this.minAmt,
  });

  factory CouponInfo.fromJson(Map<String, dynamic> json) => CouponInfo(
        id: json["id"],
        cImg: json["c_img"],
        expireDate: DateTime.parse(json["expire_date"]),
        description: json["description"],
        couponVal: json["coupon_val"],
        couponCode: json["coupon_code"],
        couponTitle: json["coupon_title"],
        couponSubtitle: json["coupon_subtitle"],
        minAmt: json["min_amt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "c_img": cImg,
        "expire_date":
            "${expireDate.year.toString().padLeft(4, '0')}-${expireDate.month.toString().padLeft(2, '0')}-${expireDate.day.toString().padLeft(2, '0')}",
        "description": description,
        "coupon_val": couponVal,
        "coupon_code": couponCode,
        "coupon_title": couponTitle,
        "coupon_subtitle": couponSubtitle,
        "min_amt": minAmt,
      };
}
