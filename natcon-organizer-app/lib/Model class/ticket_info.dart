// To parse this JSON data, do
//
//     final ticketInfo = ticketInfoFromJson(jsonString);

import 'dart:convert';

TicketInfo ticketInfoFromJson(String str) =>
    TicketInfo.fromJson(json.decode(str));

String ticketInfoToJson(TicketInfo data) => json.encode(data.toJson());

class TicketInfo {
  String ticketId;
  String uid;
  String eventId;
  String orgnizerId;

  TicketInfo({
    required this.ticketId,
    required this.uid,
    required this.eventId,
    required this.orgnizerId,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) => TicketInfo(
        ticketId: json["ticket_id"],
        uid: json["uid"],
        eventId: json["event_id"],
        orgnizerId: json["orgnizer_id"],
      );

  Map<String, dynamic> toJson() => {
        "ticket_id": ticketId,
        "uid": uid,
        "event_id": eventId,
        "orgnizer_id": orgnizerId,
      };
}
