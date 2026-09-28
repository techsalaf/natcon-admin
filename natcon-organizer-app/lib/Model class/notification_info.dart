// To parse this JSON data, do
//
//     final notificationInfo = notificationInfoFromJson(jsonString);

import 'dart:convert';

NotificationInfo notificationInfoFromJson(String str) =>
    NotificationInfo.fromJson(json.decode(str));

String notificationInfoToJson(NotificationInfo data) =>
    json.encode(data.toJson());

class NotificationInfo {
  List<NotificationDatum> notificationData;
  String responseCode;
  String result;
  String responseMsg;

  NotificationInfo({
    required this.notificationData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) =>
      NotificationInfo(
        notificationData: List<NotificationDatum>.from(
            json["NotificationData"].map((x) => NotificationDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "NotificationData":
            List<dynamic>.from(notificationData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class NotificationDatum {
  String id;
  String oragId;
  DateTime datetime;
  String title;
  String description;

  NotificationDatum({
    required this.id,
    required this.oragId,
    required this.datetime,
    required this.title,
    required this.description,
  });

  factory NotificationDatum.fromJson(Map<String, dynamic> json) =>
      NotificationDatum(
        id: json["id"],
        oragId: json["orag_id"],
        datetime: DateTime.parse(json["datetime"]),
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orag_id": oragId,
        "datetime": datetime.toIso8601String(),
        "title": title,
        "description": description,
      };
}
