// To parse this JSON data, do
//
//     final userInfo = userInfoFromJson(jsonString);

import 'dart:convert';

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

String userInfoToJson(UserInfo data) => json.encode(data.toJson());

class UserInfo {
  List<JoinedUserdatum> joinedUserdata;
  String responseCode;
  String result;
  String responseMsg;

  UserInfo({
    required this.joinedUserdata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        joinedUserdata: List<JoinedUserdatum>.from(
            json["JoinedUserdata"].map((x) => JoinedUserdatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "JoinedUserdata":
            List<dynamic>.from(joinedUserdata.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class JoinedUserdatum {
  String userImg;
  String customername;
  String totalTicketPurchase;
  String totalType;

  JoinedUserdatum({
    required this.userImg,
    required this.customername,
    required this.totalTicketPurchase,
    required this.totalType,
  });

  factory JoinedUserdatum.fromJson(Map<String, dynamic> json) =>
      JoinedUserdatum(
        userImg: json["user_img"],
        customername: json["customername"],
        totalTicketPurchase: json["Total_ticket_purchase"],
        totalType: json["Total_type"],
      );

  Map<String, dynamic> toJson() => {
        "user_img": userImg,
        "customername": customername,
        "Total_ticket_purchase": totalTicketPurchase,
        "Total_type": totalType,
      };
}
