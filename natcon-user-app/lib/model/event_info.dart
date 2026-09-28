// To parse this JSON data, do
//
//     final eventInfo = eventInfoFromJson(jsonString);

import 'dart:convert';

EventInfo eventInfoFromJson(String str) => EventInfo.fromJson(json.decode(str));

String eventInfoToJson(EventInfo data) => json.encode(data.toJson());

class EventInfo {
  String responseCode;
  String result;
  String responseMsg;
  EventData eventData;
  List<String> eventGallery;
  List<EventArtist> eventArtist;
  List<EventFacility> eventFacility;
  List<EventRestriction> eventRestriction;
  List<Reviewdatum> reviewdata;

  EventInfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.eventData,
    required this.eventGallery,
    required this.eventArtist,
    required this.eventFacility,
    required this.eventRestriction,
    required this.reviewdata,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) => EventInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        eventData: EventData.fromJson(json["EventData"]),
        eventGallery: List<String>.from(json["Event_gallery"].map((x) => x)),
        eventArtist: List<EventArtist>.from(
            json["Event_Artist"].map((x) => EventArtist.fromJson(x))),
        eventFacility: List<EventFacility>.from(
            json["Event_Facility"].map((x) => EventFacility.fromJson(x))),
        eventRestriction: List<EventRestriction>.from(
            json["Event_Restriction"].map((x) => EventRestriction.fromJson(x))),
        reviewdata: List<Reviewdatum>.from(
            json["reviewdata"].map((x) => Reviewdatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "EventData": eventData.toJson(),
        "Event_gallery": List<dynamic>.from(eventGallery.map((x) => x)),
        "Event_Artist": List<dynamic>.from(eventArtist.map((x) => x.toJson())),
        "Event_Facility":
            List<dynamic>.from(eventFacility.map((x) => x.toJson())),
        "Event_Restriction":
            List<dynamic>.from(eventRestriction.map((x) => x.toJson())),
        "reviewdata": List<dynamic>.from(reviewdata.map((x) => x.toJson())),
      };
}

class EventArtist {
  String artistImg;
  String artistTitle;
  String artistRole;

  EventArtist({
    required this.artistImg,
    required this.artistTitle,
    required this.artistRole,
  });

  factory EventArtist.fromJson(Map<String, dynamic> json) => EventArtist(
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

class EventData {
  String eventId;
  String eventTitle;
  String eventImg;
  List<String> eventCoverImg;
  String eventSdate;
  String eventTimeDay;
  String eventAddressTitle;
  String eventAddress;
  String eventLatitude;
  String eventLongtitude;
  String eventDisclaimer;
  String eventAbout;
  List<String> eventTags;
  List<String> eventVideoUrls;
  String ticketPrice;
  int isBookmark;
  String sponsoreId;
  String sponsoreImg;
  String sponsoreName;
  String sponsoreMobile;
  int totalTicket;
  int isJoined;
  int totalBookTicket;
  List<String> memberList;

  EventData({
    required this.eventId,
    required this.eventTitle,
    required this.eventImg,
    required this.eventCoverImg,
    required this.eventSdate,
    required this.eventTimeDay,
    required this.eventAddressTitle,
    required this.eventAddress,
    required this.eventLatitude,
    required this.eventLongtitude,
    required this.eventDisclaimer,
    required this.eventAbout,
    required this.eventTags,
    required this.eventVideoUrls,
    required this.ticketPrice,
    required this.isBookmark,
    required this.sponsoreId,
    required this.sponsoreImg,
    required this.sponsoreName,
    required this.sponsoreMobile,
    required this.totalTicket,
    required this.isJoined,
    required this.totalBookTicket,
    required this.memberList,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        eventImg: json["event_img"],
        eventCoverImg: List<String>.from(json["event_cover_img"].map((x) => x)),
        eventSdate: json["event_sdate"],
        eventTimeDay: json["event_time_day"],
        eventAddressTitle: json["event_address_title"],
        eventAddress: json["event_address"],
        eventLatitude: json["event_latitude"],
        eventLongtitude: json["event_longtitude"],
        eventDisclaimer: json["event_disclaimer"],
        eventAbout: json["event_about"],
        eventTags: List<String>.from(json["event_tags"].map((x) => x)),
        eventVideoUrls: List<String>.from(
            json["event_video_urls"].map((x) => x.toString())),
        ticketPrice: json["ticket_price"],
        isBookmark: json["IS_BOOKMARK"],
        sponsoreId: json["sponsore_id"].toString(),
        sponsoreImg: json["sponsore_img"].toString(),
        sponsoreName: json["sponsore_name"].toString(),
        sponsoreMobile: json["sponsore_mobile"].toString(),
        totalTicket: json["total_ticket"],
        isJoined: json["is_joined"],
        totalBookTicket: json["total_book_ticket"],
        memberList: List<String>.from(json["member_list"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_title": eventTitle,
        "event_img": eventImg,
        "event_cover_img": List<dynamic>.from(eventCoverImg.map((x) => x)),
        "event_sdate": eventSdate,
        "event_time_day": eventTimeDay,
        "event_address_title": eventAddressTitle,
        "event_address": eventAddress,
        "event_latitude": eventLatitude,
        "event_longtitude": eventLongtitude,
        "event_disclaimer": eventDisclaimer,
        "event_about": eventAbout,
        "event_tags": List<dynamic>.from(eventTags.map((x) => x)),
        "event_video_urls": List<dynamic>.from(eventVideoUrls.map((x) => x)),
        "ticket_price": ticketPrice,
        "IS_BOOKMARK": isBookmark,
        "sponsore_id": sponsoreId,
        "sponsore_img": sponsoreImg,
        "sponsore_name": sponsoreName,
        "sponsore_mobile": sponsoreMobile,
        "total_ticket": totalTicket,
        "is_joined": isJoined,
        "total_book_ticket": totalBookTicket,
        "member_list": List<dynamic>.from(memberList.map((x) => x)),
      };
}

class EventFacility {
  String facilityImg;
  String facilityTitle;

  EventFacility({
    required this.facilityImg,
    required this.facilityTitle,
  });

  factory EventFacility.fromJson(Map<String, dynamic> json) => EventFacility(
        facilityImg: json["facility_img"],
        facilityTitle: json["facility_title"],
      );

  Map<String, dynamic> toJson() => {
        "facility_img": facilityImg,
        "facility_title": facilityTitle,
      };
}

class EventRestriction {
  String restrictionImg;
  String restrictionTitle;

  EventRestriction({
    required this.restrictionImg,
    required this.restrictionTitle,
  });

  factory EventRestriction.fromJson(Map<String, dynamic> json) =>
      EventRestriction(
        restrictionImg: json["restriction_img"],
        restrictionTitle: json["restriction_title"],
      );

  Map<String, dynamic> toJson() => {
        "restriction_img": restrictionImg,
        "restriction_title": restrictionTitle,
      };
}

class Reviewdatum {
  String userImg;
  String customername;
  String rateNumber;
  String rateText;

  Reviewdatum({
    required this.userImg,
    required this.customername,
    required this.rateNumber,
    required this.rateText,
  });

  factory Reviewdatum.fromJson(Map<String, dynamic> json) => Reviewdatum(
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
