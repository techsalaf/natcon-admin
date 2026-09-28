import 'dart:convert';

TwilioOtpModel twilioOtpModelFromJson(String str) => TwilioOtpModel.fromJson(json.decode(str));

String twilioOtpModelToJson(TwilioOtpModel data) => json.encode(data.toJson());

class TwilioOtpModel {
  String responseCode;
  String result;
  String responseMsg;
  int otp;

  TwilioOtpModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.otp,
  });

  factory TwilioOtpModel.fromJson(Map<String, dynamic> json) => TwilioOtpModel(
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
