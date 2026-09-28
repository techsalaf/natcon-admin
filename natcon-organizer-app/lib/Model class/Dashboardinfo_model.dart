// To parse this JSON data, do
//
//     final dashboardinfo = dashboardinfoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

Dashboardinfo dashboardinfoFromJson(String str) =>
    Dashboardinfo.fromJson(json.decode(str));

String dashboardinfoToJson(Dashboardinfo data) => json.encode(data.toJson());

class Dashboardinfo {
  String responseCode;
  String result;
  String responseMsg;
  List<ReportDatum> reportData;
  String withdrawLimit;

  Dashboardinfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.reportData,
    required this.withdrawLimit,
  });

  factory Dashboardinfo.fromJson(Map<String, dynamic> json) => Dashboardinfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        reportData: List<ReportDatum>.from(
            json["report_data"].map((x) => ReportDatum.fromJson(x))),
        withdrawLimit: json["withdraw_limit"],
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "report_data": List<dynamic>.from(reportData.map((x) => x.toJson())),
        "withdraw_limit": withdrawLimit,
      };
}

class ReportDatum {
  String title;
  dynamic reportData;
  String url;

  ReportDatum({
    required this.title,
    required this.reportData,
    required this.url,
  });

  factory ReportDatum.fromJson(Map<String, dynamic> json) => ReportDatum(
        title: json["title"],
        reportData: json["report_data"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "report_data": reportData,
        "url": url,
      };
}
