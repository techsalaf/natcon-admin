// To parse this JSON data, do
//
//     final eventInfo = eventInfoFromJson(jsonString);

import 'dart:convert';

EventInfo eventInfoFromJson(String str) => EventInfo.fromJson(json.decode(str));

String eventInfoToJson(EventInfo data) => json.encode(data.toJson());

class EventInfo {
  Eventdata? eventdata;
  String? responseCode;
  String? result;
  String? responseMsg;

  EventInfo({
    this.eventdata,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) => EventInfo(
    eventdata: json["Eventdata"] == null ? null : Eventdata.fromJson(json["Eventdata"]),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "Eventdata": eventdata?.toJson(),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Eventdata {
  String? eventId;
  String? eventTitle;
  String? eventCoverImg;
  String? eventImage;
  String? eventStatus;
  DateTime? eventStartDate;
  String? eventStartTime;
  String? eventEndTime;
  String? eventAddress;
  String? eventDescription;
  String? eventDisclaimer;
  String? eventLatitude;
  String? eventLongtitude;
  String? eventProgress;
  String? eventPlaceName;
  String? eventTypeList;
  dynamic eventRevnue;
  String? ticketPrice;
  String? eventTags;
  String? eventVurls;
  int? totalTicket;
  int? totalBookTicket;
  List<String>? gallerydata;
  List<Artistdatum>? artistdata;
  List<Facilitydatum>? facilitydata;
  List<Restrictiondatum>? restrictiondata;
  List<DUser>? joinedUser;
  List<DUser>? attendUser;
  List<DUser>? notjoinedUser;
  List<TotalReview>? totalReview;

  Eventdata({
    this.eventId,
    this.eventTitle,
    this.eventCoverImg,
    this.eventImage,
    this.eventStatus,
    this.eventStartDate,
    this.eventStartTime,
    this.eventEndTime,
    this.eventAddress,
    this.eventDescription,
    this.eventDisclaimer,
    this.eventLatitude,
    this.eventLongtitude,
    this.eventProgress,
    this.eventPlaceName,
    this.eventTypeList,
    this.eventRevnue,
    this.ticketPrice,
    this.eventTags,
    this.eventVurls,
    this.totalTicket,
    this.totalBookTicket,
    this.gallerydata,
    this.artistdata,
    this.facilitydata,
    this.restrictiondata,
    this.joinedUser,
    this.attendUser,
    this.notjoinedUser,
    this.totalReview,
  });

  factory Eventdata.fromJson(Map<String, dynamic> json) => Eventdata(
    eventId: json["event_id"],
    eventTitle: json["event_title"],
    eventCoverImg: json["event_cover_img"],
    eventImage: json["event_image"],
    eventStatus: json["event_status"],
    eventStartDate: json["event_start_date"] == null ? null : DateTime.parse(json["event_start_date"]),
    eventStartTime: json["event_start_time"],
    eventEndTime: json["event_end_time"],
    eventAddress: json["event_address"],
    eventDescription: json["event_description"],
    eventDisclaimer: json["event_disclaimer"],
    eventLatitude: json["event_latitude"],
    eventLongtitude: json["event_longtitude"],
    eventProgress: json["event_progress"],
    eventPlaceName: json["event_place_name"],
    eventTypeList: json["event_type_list"],
    eventRevnue: json["event_revnue"],
    ticketPrice: json["ticket_price"],
    eventTags: json["event_tags"],
    eventVurls: json["event_vurls"],
    totalTicket: json["total_ticket"],
    totalBookTicket: json["total_book_ticket"],
    gallerydata: json["gallerydata"] == null ? [] : List<String>.from(json["gallerydata"]!.map((x) => x)),
    artistdata: json["artistdata"] == null ? [] : List<Artistdatum>.from(json["artistdata"]!.map((x) => Artistdatum.fromJson(x))),
    facilitydata: json["facilitydata"] == null ? [] : List<Facilitydatum>.from(json["facilitydata"]!.map((x) => Facilitydatum.fromJson(x))),
    restrictiondata: json["restrictiondata"] == null ? [] : List<Restrictiondatum>.from(json["restrictiondata"]!.map((x) => Restrictiondatum.fromJson(x))),
    joinedUser: json["joined_user"] == null ? [] : List<DUser>.from(json["joined_user"]!.map((x) => DUser.fromJson(x))),
    attendUser: json["attend_user"] == null ? [] : List<DUser>.from(json["attend_user"]!.map((x) => DUser.fromJson(x))),
    notjoinedUser: json["notjoined_user"] == null ? [] : List<DUser>.from(json["notjoined_user"]!.map((x) => DUser.fromJson(x))),
    totalReview: json["total_review"] == null ? [] : List<TotalReview>.from(json["total_review"]!.map((x) => TotalReview.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "event_id": eventId,
    "event_title": eventTitle,
    "event_cover_img": eventCoverImg,
    "event_image": eventImage,
    "event_status": eventStatus,
    "event_start_date": "${eventStartDate!.year.toString().padLeft(4, '0')}-${eventStartDate!.month.toString().padLeft(2, '0')}-${eventStartDate!.day.toString().padLeft(2, '0')}",
    "event_start_time": eventStartTime,
    "event_end_time": eventEndTime,
    "event_address": eventAddress,
    "event_description": eventDescription,
    "event_disclaimer": eventDisclaimer,
    "event_latitude": eventLatitude,
    "event_longtitude": eventLongtitude,
    "event_progress": eventProgress,
    "event_place_name": eventPlaceName,
    "event_type_list": eventTypeList,
    "event_revnue": eventRevnue,
    "ticket_price": ticketPrice,
    "event_tags": eventTags,
    "event_vurls": eventVurls,
    "total_ticket": totalTicket,
    "total_book_ticket": totalBookTicket,
    "gallerydata": gallerydata == null ? [] : List<dynamic>.from(gallerydata!.map((x) => x)),
    "artistdata": artistdata == null ? [] : List<dynamic>.from(artistdata!.map((x) => x.toJson())),
    "facilitydata": facilitydata == null ? [] : List<dynamic>.from(facilitydata!.map((x) => x.toJson())),
    "restrictiondata": restrictiondata == null ? [] : List<dynamic>.from(restrictiondata!.map((x) => x.toJson())),
    "joined_user": joinedUser == null ? [] : List<dynamic>.from(joinedUser!.map((x) => x.toJson())),
    "attend_user": attendUser == null ? [] : List<dynamic>.from(attendUser!.map((x) => x.toJson())),
    "notjoined_user": notjoinedUser == null ? [] : List<dynamic>.from(notjoinedUser!.map((x) => x.toJson())),
    "total_review": totalReview == null ? [] : List<dynamic>.from(totalReview!.map((x) => x.toJson())),
  };
}

class Artistdatum {
  String? artistImg;
  String? artistTitle;
  String? artistRole;

  Artistdatum({
    this.artistImg,
    this.artistTitle,
    this.artistRole,
  });

  factory Artistdatum.fromJson(Map<String, dynamic> json) => Artistdatum(
    artistImg: json["artist_img"],
    artistTitle: json["artist_title"],
    artistRole: json["artist_role"],
  );

  Map<String, dynamic> toJson() => {
    "artist_img": artistImg,
    "artist_title": artistTitle,
    "artist_role": artistRole,
  };
}

class DUser {
  String? userImg;
  String? customername;
  String? customermobile;
  String? totalTicketPurchase;
  String? totalType;

  DUser({
    this.userImg,
    this.customername,
    this.customermobile,
    this.totalTicketPurchase,
    this.totalType,
  });

  factory DUser.fromJson(Map<String, dynamic> json) => DUser(
    userImg: json["user_img"],
    customername: json["customername"],
    customermobile: json["customermobile"],
    totalTicketPurchase: json["Total_ticket_purchase"],
    totalType: json["Total_type"],
  );

  Map<String, dynamic> toJson() => {
    "user_img": userImg,
    "customername": customername,
    "customermobile": customermobile,
    "Total_ticket_purchase": totalTicketPurchase,
    "Total_type": totalType,
  };
}

class Facilitydatum {
  String? facilityImg;
  String? facilityTitle;

  Facilitydatum({
    this.facilityImg,
    this.facilityTitle,
  });

  factory Facilitydatum.fromJson(Map<String, dynamic> json) => Facilitydatum(
    facilityImg: json["facility_img"],
    facilityTitle: json["facility_title"],
  );

  Map<String, dynamic> toJson() => {
    "facility_img": facilityImg,
    "facility_title": facilityTitle,
  };
}

class Restrictiondatum {
  String? restrictionImg;
  String? restrictionTitle;

  Restrictiondatum({
    this.restrictionImg,
    this.restrictionTitle,
  });

  factory Restrictiondatum.fromJson(Map<String, dynamic> json) => Restrictiondatum(
    restrictionImg: json["restriction_img"],
    restrictionTitle: json["restriction_title"],
  );

  Map<String, dynamic> toJson() => {
    "restriction_img": restrictionImg,
    "restriction_title": restrictionTitle,
  };
}

class TotalReview {
  String? userImg;
  String? customername;
  String? rateNumber;
  String? rateText;

  TotalReview({
    this.userImg,
    this.customername,
    this.rateNumber,
    this.rateText,
  });

  factory TotalReview.fromJson(Map<String, dynamic> json) => TotalReview(
    userImg: json["user_img"],
    customername: json["customername"],
    rateNumber: json["rate_number"],
    rateText: json["rate_text"],
  );

  Map<String, dynamic> toJson() => {
    "user_img": userImg,
    "customername": customername,
    "rate_number": rateNumber,
    "rate_text": rateText,
  };
}
