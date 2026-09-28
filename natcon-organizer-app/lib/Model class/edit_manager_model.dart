import 'dart:convert';

EditManagerModel editManagerModelFromJson(String str) => EditManagerModel.fromJson(json.decode(str));

String editManagerModelToJson(EditManagerModel data) => json.encode(data.toJson());

class EditManagerModel {
  String responseCode;
  String result;
  String responseMsg;

  EditManagerModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory EditManagerModel.fromJson(Map<String, dynamic> json) => EditManagerModel(
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
