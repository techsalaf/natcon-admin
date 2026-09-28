// To parse this JSON data, do
//
//     final ticketInfo = ticketInfoFromJson(jsonString);

import 'dart:convert';

TicketInfo ticketInfoFromJson(String str) =>
    TicketInfo.fromJson(json.decode(str));

String ticketInfoToJson(TicketInfo data) => json.encode(data.toJson());

class TicketInfo {
  String responseCode;
  String result;
  String responseMsg;
  List<EventTypePrice> eventTypePrice;

  TicketInfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.eventTypePrice,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) => TicketInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        eventTypePrice: List<EventTypePrice>.from(
            json["EventTypePrice"].map((x) => EventTypePrice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "EventTypePrice":
            List<dynamic>.from(eventTypePrice.map((x) => x.toJson())),
      };
}

class EventTypePrice {
  String typeid;
  String ticketType;
  String ticketPrice;
  int totalTicket;
  String description;
  int remainTicket;
  String tPrice = "0";

  EventTypePrice({
    required this.typeid,
    required this.ticketType,
    required this.ticketPrice,
    required this.totalTicket,
    required this.description,
    required this.remainTicket,
    required this.tPrice,
  });

  factory EventTypePrice.fromJson(Map<String, dynamic> json) => EventTypePrice(
        typeid: json["typeid"],
        ticketType: json["ticket_type"],
        ticketPrice: json["ticket_price"],
        totalTicket: json["TotalTicket"],
        description: json["description"],
        remainTicket: json["remainTicket"],
        tPrice: json["tPrice"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "typeid": typeid,
        "ticket_type": ticketType,
        "ticket_price": ticketPrice,
        "TotalTicket": totalTicket,
        "description": description,
        "remainTicket": remainTicket,
        "tPrice": tPrice,
      };
}
