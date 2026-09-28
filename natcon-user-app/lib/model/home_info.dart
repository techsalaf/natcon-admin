// To parse this JSON data, do
//
//     final homeInfo = homeInfoFromJson(jsonString);

import 'dart:convert';

HomeInfo homeInfoFromJson(String str) => HomeInfo.fromJson(json.decode(str));

String homeInfoToJson(HomeInfo data) => json.encode(data.toJson());

class HomeInfo {
  String responseCode;
  String result;
  String responseMsg;
  HomeData homeData;

  HomeInfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.homeData,
  });

  factory HomeInfo.fromJson(Map<String, dynamic> json) => HomeInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        homeData: HomeData.fromJson(json["HomeData"]),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "HomeData": homeData.toJson(),
      };
}

class HomeData {
  List<Catlist> catlist;
  MainData mainData;
  List<Event> latestEvent;
  dynamic wallet;
  List<Event> upcomingEvent;
  List<NearbyEvent> nearbyEvent;
  List<Event> thisMonthEvent;

  HomeData({
    required this.catlist,
    required this.mainData,
    required this.latestEvent,
    required this.wallet,
    required this.upcomingEvent,
    required this.nearbyEvent,
    required this.thisMonthEvent,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        catlist:
            List<Catlist>.from(json["Catlist"].map((x) => Catlist.fromJson(x))),
        mainData: MainData.fromJson(json["Main_Data"]),
        latestEvent: List<Event>.from(
            json["latest_event"].map((x) => Event.fromJson(x))),
        wallet: json["wallet"],
        upcomingEvent: List<Event>.from(
            json["upcoming_event"].map((x) => Event.fromJson(x))),
        nearbyEvent: List<NearbyEvent>.from(
            json["nearby_event"].map((x) => NearbyEvent.fromJson(x))),
        thisMonthEvent: List<Event>.from(
            json["this_month_event"].map((x) => Event.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Catlist": List<dynamic>.from(catlist.map((x) => x.toJson())),
        "Main_Data": mainData.toJson(),
        "latest_event": List<dynamic>.from(latestEvent.map((x) => x.toJson())),
        "wallet": wallet,
        "upcoming_event":
            List<dynamic>.from(upcomingEvent.map((x) => x.toJson())),
        "nearby_event": List<dynamic>.from(nearbyEvent.map((x) => x.toJson())),
        "this_month_event":
            List<dynamic>.from(thisMonthEvent.map((x) => x.toJson())),
      };
}

class Catlist {
  String id;
  String title;
  String catImg;
  String coverImg;
  int totalEvent;

  Catlist({
    required this.id,
    required this.title,
    required this.catImg,
    required this.coverImg,
    required this.totalEvent,
  });

  factory Catlist.fromJson(Map<String, dynamic> json) => Catlist(
        id: json["id"],
        title: json["title"],
        catImg: json["cat_img"],
        coverImg: json["cover_img"],
        totalEvent: json["total_event"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "cat_img": catImg,
        "cover_img": coverImg,
        "total_event": totalEvent,
      };
}

class Event {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;

  Event({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventSdate: json["event_sdate"],
        eventPlaceName: json["event_place_name"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_sdate": eventSdate,
        "event_place_name": eventPlaceName,
      };
}

class MainData {
  String id;
  String currency;
  String scredit;
  String rcredit;
  String tax;

  MainData({
    required this.id,
    required this.currency,
    required this.scredit,
    required this.rcredit,
    required this.tax,
  });

  factory MainData.fromJson(Map<String, dynamic> json) => MainData(
        id: json["id"],
        currency: json["currency"],
        scredit: json["scredit"],
        rcredit: json["rcredit"],
        tax: json["tax"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "scredit": scredit,
        "rcredit": rcredit,
        "tax": tax,
      };
}

class NearbyEvent {
  String eventId;
  String eventTitle;
  String eventImg;
  String eventSdate;
  String eventPlaceName;
  String eventLatitude;
  String eventLongtitude;

  NearbyEvent({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventSdate,
    required this.eventPlaceName,
    required this.eventLatitude,
    required this.eventLongtitude,
  });

  factory NearbyEvent.fromJson(Map<String, dynamic> json) => NearbyEvent(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventSdate: json["event_sdate"],
        eventPlaceName: json["event_place_name"],
        eventLatitude: json["event_latitude"],
        eventLongtitude: json["event_longtitude"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_sdate": eventSdate,
        "event_place_name": eventPlaceName,
        "event_latitude": eventLatitude,
        "event_longtitude": eventLongtitude,
      };
}
