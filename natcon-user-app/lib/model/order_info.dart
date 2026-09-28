// To parse this JSON data, do
//
//     final orderInfo = orderInfoFromJson(jsonString);

import 'dart:convert';

OrderInfo orderInfoFromJson(String str) => OrderInfo.fromJson(json.decode(str));

String orderInfoToJson(OrderInfo data) => json.encode(data.toJson());

class OrderInfo {
  List<OrderDatum> orderData;
  String responseCode;
  String result;
  String responseMsg;

  OrderInfo({
    required this.orderData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) => OrderInfo(
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
  String ticketId;
  String totalTicket;
  String ticketType;
  double bookMintues;

  OrderDatum({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
    required this.ticketId,
    required this.totalTicket,
    required this.ticketType,
    required this.bookMintues,
  });

  factory OrderDatum.fromJson(Map<String, dynamic> json) => OrderDatum(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventSdate: json["event_sdate"],
        eventPlaceName: json["event_place_name"],
        ticketId: json["ticket_id"],
        totalTicket: json["total_ticket"],
        ticketType: json["ticket_type"],
        bookMintues: json["book_mintues"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_sdate": eventSdate,
        "event_place_name": eventPlaceName,
        "ticket_id": ticketId,
        "total_ticket": totalTicket,
        "ticket_type": ticketType,
        "book_mintues": bookMintues,
      };
}
