// To parse this JSON data, do
//
//     final orgInfo = orgInfoFromJson(jsonString);

import 'dart:convert';

OrgInfo orgInfoFromJson(String str) => OrgInfo.fromJson(json.decode(str));

String orgInfoToJson(OrgInfo data) => json.encode(data.toJson());

class OrgInfo {
  List<OrderDatum> orderData;
  String responseCode;
  String result;
  String responseMsg;

  OrgInfo({
    required this.orderData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory OrgInfo.fromJson(Map<String, dynamic> json) => OrgInfo(
        orderData: List<OrderDatum>.from(
            json["order_data"].map((x) => OrderDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "order_data": List<dynamic>.from(orderData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class OrderDatum {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;

  OrderDatum({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
  });

  factory OrderDatum.fromJson(Map<String, dynamic> json) => OrderDatum(
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
