// To parse this JSON data, do
//
//     final myTicketInfo = myTicketInfoFromJson(jsonString);

import 'dart:convert';

MyTicketInfo myTicketInfoFromJson(String str) =>
    MyTicketInfo.fromJson(json.decode(str));

String myTicketInfoToJson(MyTicketInfo data) => json.encode(data.toJson());

class MyTicketInfo {
  String responseCode;
  String result;
  String responseMsg;
  TicketData ticketData;

  MyTicketInfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.ticketData,
  });

  factory MyTicketInfo.fromJson(Map<String, dynamic> json) => MyTicketInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        ticketData: TicketData.fromJson(json["TicketData"]),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "TicketData": ticketData.toJson(),
      };
}

class TicketData {
  String ticketId;
  String ticketTitle;
  String startTime;
  String eventAddress;
  String eventAddressTitle;
  String eventLatitude;
  String eventLongtitude;
  String sponsoreId;
  String sponsoreImg;
  String sponsoreTitle;
  String qrcode;
  String uniqueCode;
  String ticketUsername;
  String ticketMobile;
  String ticketEmail;
  String ticketRate;
  String ticketType;
  String totalTicket;
  String ticketSubtotal;
  String ticketCouAmt;
  String ticketWallAmt;
  String ticketTax;
  String ticketTotalAmt;
  String ticketPMethod;
  String ticketTransactionId;
  String ticketStatus;

  TicketData({
    required this.ticketId,
    required this.ticketTitle,
    required this.startTime,
    required this.eventAddress,
    required this.eventAddressTitle,
    required this.eventLatitude,
    required this.eventLongtitude,
    required this.sponsoreId,
    required this.sponsoreImg,
    required this.sponsoreTitle,
    required this.qrcode,
    required this.uniqueCode,
    required this.ticketUsername,
    required this.ticketMobile,
    required this.ticketEmail,
    required this.ticketRate,
    required this.ticketType,
    required this.totalTicket,
    required this.ticketSubtotal,
    required this.ticketCouAmt,
    required this.ticketWallAmt,
    required this.ticketTax,
    required this.ticketTotalAmt,
    required this.ticketPMethod,
    required this.ticketTransactionId,
    required this.ticketStatus,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
        ticketId: json["ticket_id"],
        ticketTitle: json["ticket_title"],
        startTime: json["start_time"],
        eventAddress: json["event_address"],
        eventAddressTitle: json["event_address_title"],
        eventLatitude: json["event_latitude"],
        eventLongtitude: json["event_longtitude"],
        sponsoreId: json["sponsore_id"],
        sponsoreImg: json["sponsore_img"],
        sponsoreTitle: json["sponsore_title"],
        qrcode: json["qrcode"],
        uniqueCode: json["unique_code"],
        ticketUsername: json["ticket_username"],
        ticketMobile: json["ticket_mobile"],
        ticketEmail: json["ticket_email"],
        ticketRate: json["ticket_rate"],
        ticketType: json["ticket_type"],
        totalTicket: json["total_ticket"],
        ticketSubtotal: json["ticket_subtotal"],
        ticketCouAmt: json["ticket_cou_amt"],
        ticketWallAmt: json["ticket_wall_amt"],
        ticketTax: json["ticket_tax"],
        ticketTotalAmt: json["ticket_total_amt"],
        ticketPMethod: json["ticket_p_method"],
        ticketTransactionId: json["ticket_transaction_id"],
        ticketStatus: json["ticket_status"],
      );

  Map<String, dynamic> toJson() => {
        "ticket_id": ticketId,
        "ticket_title": ticketTitle,
        "start_time": startTime,
        "event_address": eventAddress,
        "event_address_title": eventAddressTitle,
        "event_latitude": eventLatitude,
        "event_longtitude": eventLongtitude,
        "sponsore_id": sponsoreId,
        "sponsore_img": sponsoreImg,
        "sponsore_title": sponsoreTitle,
        "qrcode": qrcode,
        "unique_code": uniqueCode,
        "ticket_username": ticketUsername,
        "ticket_mobile": ticketMobile,
        "ticket_email": ticketEmail,
        "ticket_rate": ticketRate,
        "ticket_type": ticketType,
        "total_ticket": totalTicket,
        "ticket_subtotal": ticketSubtotal,
        "ticket_cou_amt": ticketCouAmt,
        "ticket_wall_amt": ticketWallAmt,
        "ticket_tax": ticketTax,
        "ticket_total_amt": ticketTotalAmt,
        "ticket_p_method": ticketPMethod,
        "ticket_transaction_id": ticketTransactionId,
        "ticket_status": ticketStatus,
      };
}
