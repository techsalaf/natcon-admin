import 'dart:convert';

SmsTypeModel smsTypeModelFromJson(String str) => SmsTypeModel.fromJson(json.decode(str));

String smsTypeModelToJson(SmsTypeModel data) => json.encode(data.toJson());

class SmsTypeModel {
  String responseCode;
  String result;
  String responseMsg;
  int otp;

  SmsTypeModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.otp,
  });

  factory SmsTypeModel.fromJson(Map<String, dynamic> json) => SmsTypeModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "otp": otp,
  };
}
