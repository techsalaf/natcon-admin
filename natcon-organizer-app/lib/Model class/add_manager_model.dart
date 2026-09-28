import 'dart:convert';

AddManagerModel addManagerModelFromJson(String str) => AddManagerModel.fromJson(json.decode(str));

String addManagerModelToJson(AddManagerModel data) => json.encode(data.toJson());

class AddManagerModel {
  String responseCode;
  String result;
  String responseMsg;

  AddManagerModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory AddManagerModel.fromJson(Map<String, dynamic> json) => AddManagerModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}
