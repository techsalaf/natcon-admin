import 'dart:convert';

PayStackApiApiModel payStackApiApiModelFromJson(String str) => PayStackApiApiModel.fromJson(json.decode(str));

String payStackApiApiModelToJson(PayStackApiApiModel data) => json.encode(data.toJson());

class PayStackApiApiModel {
  bool status;
  String message;
  Data data;

  PayStackApiApiModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PayStackApiApiModel.fromJson(Map<String, dynamic> json) => PayStackApiApiModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String authorizationUrl;
  String accessCode;
  String reference;

  Data({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    authorizationUrl: json["authorization_url"],
    accessCode: json["access_code"],
    reference: json["reference"],
  );

  Map<String, dynamic> toJson() => {
    "authorization_url": authorizationUrl,
    "access_code": accessCode,
    "reference": reference,
  };
}