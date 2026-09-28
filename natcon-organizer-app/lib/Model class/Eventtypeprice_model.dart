// To parse this JSON data, do
//
//     final eventtypepriceinfo = eventtypepriceinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Eventtypepriceinfo eventtypepriceinfoFromJson(String str) =>
    Eventtypepriceinfo.fromJson(json.decode(str));

String eventtypepriceinfoToJson(Eventtypepriceinfo data) =>
    json.encode(data.toJson());

class Eventtypepriceinfo {
  List<TypePricedatum> typePricedata;
  String responseCode;
  String result;
  String responseMsg;

  Eventtypepriceinfo({
    required this.typePricedata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Eventtypepriceinfo.fromJson(Map<String, dynamic> json) =>
      Eventtypepriceinfo(
        typePricedata: List<TypePricedatum>.from(
            json["TypePricedata"].map((x) => TypePricedatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "TypePricedata":
            List<dynamic>.from(typePricedata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class TypePricedatum {
  String id;
  String eventTitle;
  String eventId;
  String image;
  String type;
  String price;
  String tlimit;
  String description;
  String status;

  TypePricedatum({
    required this.id,
    required this.eventTitle,
    required this.eventId,
    required this.image,
    required this.type,
    required this.price,
    required this.tlimit,
    required this.description,
    required this.status,
  });

  factory TypePricedatum.fromJson(Map<String, dynamic> json) => TypePricedatum(
        id: json["id"],
        eventTitle: json["event_title"],
        eventId: json["event_id"],
        image: json["image"],
        type: json["type"],
        price: json["price"],
        tlimit: json["tlimit"],
        description: json["description"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "event_title": eventTitle,
        "event_id": eventId,
        "image": image,
        "type": type,
        "price": price,
        "tlimit": tlimit,
        "description": description,
        "status": status,
      };
}
