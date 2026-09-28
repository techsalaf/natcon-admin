import 'dart:convert';

ManagerListModel managerListModelFromJson(String str) => ManagerListModel.fromJson(json.decode(str));

String managerListModelToJson(ManagerListModel data) => json.encode(data.toJson());

class ManagerListModel {
  List<Managerdatum> managerdata;
  String responseCode;
  String result;
  String responseMsg;

  ManagerListModel({
    required this.managerdata,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory ManagerListModel.fromJson(Map<String, dynamic> json) => ManagerListModel(
    managerdata: List<Managerdatum>.from(json["Managerdata"].map((x) => Managerdatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "Managerdata": List<dynamic>.from(managerdata.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Managerdatum {
  String id;
  String name;
  String managerType;
  String status;
  String email;
  String password;

  Managerdatum({
    required this.id,
    required this.name,
    required this.managerType,
    required this.status,
    required this.email,
    required this.password,
  });

  factory Managerdatum.fromJson(Map<String, dynamic> json) => Managerdatum(
    id: json["id"],
    name: json["name"],
    managerType: json["manager_type"],
    status: json["status"],
    email: json["email"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "manager_type": managerType,
    "status": status,
    "email": email,
    "password": password,
  };
}
