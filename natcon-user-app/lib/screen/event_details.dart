// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, deprecated_member_use, must_be_immutable, sized_box_for_whitespace, avoid_unnecessary_containers

import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_stack/image_stack.dart';
import 'package:magicmate_user/screen/seeAll/gallery_view.dart';
import 'package:magicmate_user/screen/seeAll/video_view.dart';
import 'package:magicmate_user/screen/videopreview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/org_controller.dart';
import '../firebase/chats.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import 'organizer details/organizer_Information.dart';
import 'organizer details/userdetails_screen.dart';


class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventDetailsController eventDetailsController = Get.find();
  OrgController orgController = Get.find();

  String eventId = Get.arguments["eventId"];
  String bookStatus = Get.arguments["bookStatus"];
  late GoogleMapController
      mapController; //contrller for Google map //markers for google map
  LatLng showLocation = LatLng(27.7089427, 85.3086209);

  final List<Marker> _markers = <Marker>[];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  loadData() async {
    final Uint8List markIcons = await getImages("assets/MapPin.png", 50);
      _markers.add(
      Marker(
             markerId: MarkerId(showLocation.toString()),

        icon: BitmapDescriptor.fromBytes(markIcons),
               position: LatLng(
          double.parse(
              eventDetailsController.eventInfo?.eventData.eventLatitude ?? ""),
          double.parse(eventDetailsController.eventInfo?.eventData.eventLongtitude ?? ""),
        ),
        infoWindow: InfoWindow(),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhiteColor,
      bottomNavigationBar: GetBuilder<EventDetailsController>(
        builder: (context) {
          return bookStatus == "1"
              ? eventDetailsController.eventInfo?.eventData.totalBookTicket != eventDetailsController.eventInfo?.eventData.totalTicket
                  ? GestButton(
                      height: 50,
                      Width: Get.size.width,
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      buttoncolor: gradient.defoultColor,
                      buttontext: "Book Now".tr,
                      style: TextStyle(
                        color: WhiteColor,
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 15,
                      ),
                      onclick: () {
                        eventDetailsController.getEventTicket(eventId: eventId);
                        Get.toNamed(Routes.tikitDetailsScreen);
                      },
                    )
                  : SizedBox()
              : SizedBox();
        },
      ),
      body: GetBuilder<EventDetailsController>(builder: (context) {
        return eventDetailsController.isLoading
            ? CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    leading: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(7),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back,
                          color: WhiteColor,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF000000).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    actions: [
                      bookStatus == "1"
                          ? eventDetailsController
                                      .eventInfo?.eventData.isBookmark !=
                                  1
                              ? InkWell(
                                  onTap: () {
                                    eventDetailsController.getFavAndUnFav(
                                        eventID: eventId);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: EdgeInsets.all(7),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      "assets/Love.png",
                                      color: WhiteColor,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF000000).withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    eventDetailsController.getFavAndUnFav(
                                        eventID: eventId);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: EdgeInsets.all(9),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      "assets/Fev-Bold.png",
                                      color: gradient.defoultColor,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF000000).withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                          : SizedBox(),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                    expandedHeight: Get.height * 0.29,
                    bottom: PreferredSize(
                      child: Container(),
                      preferredSize: Size(0, 20),
                    ),
                    flexibleSpace: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: Get.height * 0.34,
                            width: double.infinity,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: Get.size.height / 3,
                                viewportFraction: 1,
                                autoPlay: true,
                              ),
                              items: eventDetailsController
                                          .eventInfo?.eventData.eventCoverImg !=
                                      []
                                  ? eventDetailsController
                                      .eventInfo?.eventData.eventCoverImg
                                      .map<Widget>((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: Get.size.width,
                                            decoration: const BoxDecoration(
                                                color: Colors.transparent),
                                            child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    "assets/ezgif.com-crop.gif",
                                                fit: BoxFit.cover,
                                                image: Config.imageUrl + i),
                                          );
                                        },
                                      );
                                    }).toList()
                                  : [].map<Widget>((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: 100,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: const BoxDecoration(
                                                color: Colors.transparent),
                                            child: Image.network(
                                              Config.imageUrl + i,
                                              fit: BoxFit.fill,
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                              // ),
                            ),
                            decoration: BoxDecoration(
                              color: transparent,
                            ),
                          ),
                        ),
                        Positioned(
                          child: Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: WhiteColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(50),
                              ),
                            ),
                          ),
                          bottom: -1,
                          left: 0,
                          right: 0,
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        eventDetailsController.eventInfo
                                                ?.eventData.eventTitle ??
                                            "",
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 18,
                                          color: BlackColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: Get.size.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(12),
                                      child: Image.asset(
                                        "assets/Calendar.png",
                                        color: gradient.defoultColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: bgcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            eventDetailsController.eventInfo
                                                    ?.eventData.eventSdate ??
                                                "",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            eventDetailsController.eventInfo
                                                    ?.eventData.eventTimeDay ??
                                                "",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              color: greytext,
                                              fontSize: 13,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: Get.size.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(12),
                                      child: Image.asset(
                                        "assets/Location2.png",
                                        color: gradient.defoultColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: bgcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            eventDetailsController.eventInfo
                                                    ?.eventData.eventAddress ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await openMap(
                                          double.parse(eventDetailsController
                                                  .eventInfo
                                                  ?.eventData
                                                  .eventLatitude ??
                                              ""),
                                          double.parse(eventDetailsController
                                                  .eventInfo
                                                  ?.eventData
                                                  .eventLongtitude ??
                                              ""),
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/mapIcons.png'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 50,
                                width: Get.size.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(12),
                                      child: Image.asset(
                                        "assets/ticketIcon.png",
                                        color: gradient.defoultColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: bgcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${eventDetailsController.eventInfo?.eventData.ticketPrice ?? ""}",
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "Ticket price ".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              color: greytext,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${int.parse(eventDetailsController.eventInfo?.eventData.totalTicket.toString() ?? "0") - int.parse(eventDetailsController.eventInfo?.eventData.totalBookTicket.toString() ?? "0")} spots left",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        color: Color(0xFFFF5E4E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          OrganizerInformation(
                                            orgImg: eventDetailsController
                                                    .eventInfo
                                                    ?.eventData
                                                    .sponsoreImg ??
                                                "",
                                            orgId: eventDetailsController
                                                    .eventInfo
                                                    ?.eventData
                                                    .sponsoreId ??
                                                "",
                                            orgName: eventDetailsController
                                                    .eventInfo
                                                    ?.eventData
                                                    .sponsoreName ??
                                                "",
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Organized By".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      Colors.purple.shade50,
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        "${Config.imageUrl}${eventDetailsController.eventInfo?.eventData.sponsoreImg ?? ""}"),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    eventDetailsController.eventInfo?.eventData.sponsoreName ?? "",
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      color: BlackColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  eventDetailsController.eventInfo?.eventData.isJoined == 1
                                                      ? SizedBox(
                                                          height: 2,
                                                        )
                                                      : SizedBox(),
                                                  eventDetailsController.eventInfo?.eventData.isJoined == 1
                                                      ? Text(
                                                          eventDetailsController.eventInfo?.eventData.sponsoreMobile ?? "",
                                                          style: TextStyle(
                                                            fontFamily: FontFamily
                                                                .gilroyMedium,
                                                            color: greytext,
                                                            fontSize: 12,
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        orgController.getJoinDataList(eventId: eventDetailsController.eventInfo?.eventData.eventId,
                                        );
                                        Get.to(UserDetailsScreen());
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          eventDetailsController.menberList.isNotEmpty
                                              ? Text(
                                                  "${"Attendees".tr}(${eventDetailsController.eventInfo?.eventData.totalBookTicket})",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    color: BlackColor,
                                                    fontSize: 14,
                                                  ),
                                                )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          eventDetailsController.menberList.isNotEmpty
                                              ? Row(
                                                  children: [
                                                    ImageStack(
                                                      imageList: eventDetailsController.menberList,
                                                      totalCount:
                                                          eventDetailsController
                                                              .menberList
                                                              .length,
                                                      imageRadius: 25,
                                                      imageCount: 5,
                                                      imageBorderWidth: 1.5,
                                                      showTotalCount: true,
                                                      extraCountTextStyle:
                                                          TextStyle(
                                                        fontFamily: FontFamily.gilroyLight,
                                                        fontSize: 10,
                                                        color: BlackColor,

                                                      ),
                                                      imageBorderColor: Colors.purple.shade50,
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                     getData.read("UserLogin") != null ?
                                    eventDetailsController.eventInfo?.eventData.isJoined == 1 ?
                                    InkWell(
                                      onTap: (){
                                        Get.to(ChatScreen(eventUid: eventDetailsController.eventInfo!.eventData.sponsoreId,));
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          eventDetailsController.menberList.isNotEmpty
                                              ? Text(
                                            "${"Chats".tr}",
                                            style: TextStyle(
                                              fontFamily:
                                              FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                            ),
                                          )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          eventDetailsController.eventInfo?.eventData.isJoined == 1
                                          ? Row(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                                  child: Image.asset('assets/Chat.png',color: gradient.defoultColor,)),
                                              SizedBox(width: 10),
                                            ],
                                          )
                                              : SizedBox(),
                                        ],
                                      ),
                                    )
                                    : SizedBox()
                                    : SizedBox(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  "About Event".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 14,
                                    color: BlackColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 10, right: 15),
                                child: HtmlWidget(
                                  eventDetailsController
                                          .eventInfo?.eventData.eventAbout ??
                                      "",
                                  textStyle: TextStyle(
                                    color: BlackColor,
                                    fontSize: 12,
                                    // fontSize: Get.height / 50,
                                    fontFamily: 'Gilroy Normal',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  "Disclaimer".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 14,
                                    color: BlackColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 10, right: 15),
                                child: HtmlWidget(
                                  eventDetailsController.eventInfo?.eventData
                                          .eventDisclaimer ??
                                      "",
                                  textStyle: TextStyle(
                                    color: BlackColor,
                                    fontSize: 12,
                                    // fontSize: Get.height / 50,
                                    fontFamily: 'Gilroy Normal',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              eventDetailsController.eventInfo!.eventArtist.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Artist".tr,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventArtist.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventArtist.isNotEmpty
                                  ? SizedBox(
                                      height: 80,
                                      width: Get.size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: ListView.builder(
                                          itemCount: eventDetailsController
                                              .eventInfo?.eventArtist.length,
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFe9f0ff),
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            "${Config.imageUrl}${eventDetailsController.eventInfo?.eventArtist[index].artistImg}"),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 5,
                                                    right: 5,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 20,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      1),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            eventDetailsController
                                                                    .eventInfo
                                                                    ?.eventArtist[
                                                                        index]
                                                                    .artistTitle ??
                                                                "",
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  FontFamily
                                                                      .gilroyBold,
                                                              fontSize: 10,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color: WhiteColor,
                                                            ),
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            color: gradient
                                                                .defoultColor,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          eventDetailsController
                                                                  .eventInfo
                                                                  ?.eventArtist[
                                                                      index]
                                                                  .artistRole ??
                                                              "",
                                                          style: TextStyle(
                                                            fontFamily: FontFamily
                                                                .gilroyMedium,
                                                            fontSize: 10,
                                                            color: greytext,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventFacility.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventFacility.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Facility".tr,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 14,
                                          color: BlackColor,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventFacility.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventFacility.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: eventDetailsController
                                            .eventInfo?.eventFacility.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 5,
                                                mainAxisExtent: 85),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              Container(
                                                height: 60,
                                                width: 60,
                                                alignment: Alignment.center,
                                                child: Image.network(
                                                  "${Config.imageUrl}${eventDetailsController.eventInfo?.eventFacility[index].facilityImg}",
                                                  height: 50,
                                                  width: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                eventDetailsController
                                                        .eventInfo
                                                        ?.eventFacility[index]
                                                        .facilityTitle ??
                                                    "",
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  fontSize: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: BlackColor,
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventRestriction.isNotEmpty
                                  ? SizedBox(
                                      height: 15,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventRestriction.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Event Prohibited".tr,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 14,
                                          color: BlackColor,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventRestriction.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventRestriction.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: eventDetailsController
                                            .eventInfo?.eventRestriction.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 5,
                                                mainAxisExtent: 85),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              Container(
                                                height: 60,
                                                width: 60,
                                                alignment: Alignment.center,
                                                child: Image.network(
                                                  "${Config.imageUrl}${eventDetailsController.eventInfo?.eventRestriction[index].restrictionImg}",
                                                  height: 50,
                                                  width: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                eventDetailsController
                                                        .eventInfo
                                                        ?.eventRestriction[
                                                            index]
                                                        .restrictionTitle ??
                                                    "",
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  fontSize: 12,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: BlackColor,
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventGallery.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController
                                      .eventInfo!.eventGallery.isNotEmpty
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          "Gallery".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            color: BlackColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(GalleryView());
                                          },
                                          child: Text(
                                            "See All".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              color: Color(0xFF6F3DE9),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventGallery.isNotEmpty
                                  ? SizedBox(
                                      height: 100,
                                      width: Get.size.width,
                                      child: ListView.builder(
                                        itemCount: eventDetailsController
                                            .eventInfo?.eventGallery.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              Get.to(PhotoViewPage(photos: eventDetailsController.eventInfo!.eventGallery,index: index),
                                              );
                                              // Get.to(
                                              //   FullScreenImage(
                                              //     imageUrl:
                                              //         "${Config.imageUrl}${eventDetailsController.eventInfo!.eventGallery[index]}",
                                              //     tag: "generate_a_unique_tag",
                                              //   ),
                                              // );
                                            },
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              margin: EdgeInsets.only(
                                                  left: 8, right: 8, bottom: 8),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "assets/ezgif.com-crop.gif",
                                                  placeholderFit: BoxFit.cover,
                                                  image:
                                                      "${Config.imageUrl}${eventDetailsController.eventInfo?.eventGallery[index] ?? ""}",
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    offset: const Offset(
                                                      0.5,
                                                      0.5,
                                                    ),
                                                    blurRadius: 0.5,
                                                    spreadRadius: 0.5,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset:
                                                        const Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventData.eventVideoUrls.isNotEmpty
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          "Video".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            color: BlackColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            Get.to(VideoViewScreen());
                                          },
                                          child: Text(
                                            "See All".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              color: Color(0xFF6F3DE9),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventData.eventVideoUrls.isNotEmpty
                              ?  Container(
                                      height: 100,
                                      width: Get.size.width,
                                      // color: Colors.red,
                                      child: ListView.builder(
                                        itemCount: eventDetailsController.eventInfo?.eventData.eventVideoUrls.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return eventDetailsController.eventInfo!.eventData.eventVideoUrls[index].toString().split(".be").first == "https://youtu"
                                              ? InkWell(
                                                  onTap: () {
                                                    Get.to(VideoPreviewScreen(
                                                      url: eventDetailsController.eventInfo?.eventData.eventVideoUrls[index] ?? "",
                                                    ));
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height: 100,
                                                        width: 100,
                                                        margin: EdgeInsets.only(
                                                            left: 8,
                                                            right: 8,
                                                            bottom: 8),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            placeholder:
                                                                "assets/ezgif.com-crop.gif",
                                                            placeholderCacheHeight:
                                                                100,
                                                            placeholderCacheWidth:
                                                                100,
                                                            placeholderFit:
                                                                BoxFit.cover,
                                                            image: YoutubePlayer.getThumbnail(
                                                              videoId: YoutubePlayer.convertUrlToId(eventDetailsController.eventInfo?.eventData.eventVideoUrls[index] ?? "")!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              offset:
                                                                  const Offset(
                                                                0.5,
                                                                0.5,
                                                              ),
                                                              blurRadius: 0.5,
                                                              spreadRadius: 0.5,
                                                            ), //BoxShadow
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              offset:
                                                                  const Offset(
                                                                      0.0, 0.0),
                                                              blurRadius: 0.0,
                                                              spreadRadius: 0.0,
                                                            ), //BoxShadow
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 35,
                                                        left: 35,
                                                        right: 35,
                                                        bottom: 35,
                                                        child: Image.asset(
                                                          "assets/videopush.png",
                                                          height: 20,
                                                          width: 20,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              :  Container(
                                            height: 100,
                                            width: 100,
                                            margin: EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                                bottom: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(15),
                                              child: Center(child: Text("Not Valid Url",style: TextStyle(
                                                fontFamily:
                                                FontFamily.gilroyMedium,
                                                color: BlackColor,
                                              ),),),
                                            ),
                                            decoration:
                                            BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(15),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .shade300,
                                                  offset:
                                                  const Offset(
                                                    0.5,
                                                    0.5,
                                                  ),
                                                  blurRadius: 0.5,
                                                  spreadRadius: 0.5,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color:
                                                  Colors.white,
                                                  offset:
                                                  const Offset(
                                                      0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )

                              : SizedBox(),


                              // InkWell(
                              //   onTap: () {
                              //     print("++++LINK+++${eventDetailsController.eventInfo!.eventData.eventVideoUrls[0].toString().split(".be/").first}");
                              //   },
                              //   child: Container(
                              //     height: 100,
                              //     width: 100,
                              //     color: Colors.red,
                              //   ),
                              // ),
                              //
                              // eventDetailsController.eventInfo!.eventData.eventVideoUrls[0].toString().split(".be").first == "https://youtu.be" ?
                              // Container(
                              //   height: 100,
                              //   width: Get.size.width,
                              //   child: ListView.builder(
                              //     itemCount: eventDetailsController
                              //         .eventInfo
                              //         ?.eventData
                              //         .eventVideoUrls
                              //         .length,
                              //     scrollDirection: Axis.horizontal,
                              //     padding: EdgeInsets.zero,
                              //     itemBuilder: (context, index) {
                              //       return eventDetailsController.eventInfo?.eventData.eventVideoUrls[index] != "null"
                              //           ? InkWell(
                              //         onTap: () {
                              //           Get.to(VideoPreviewScreen(
                              //             url: eventDetailsController
                              //                 .eventInfo
                              //                 ?.eventData
                              //                 .eventVideoUrls[
                              //             index] ??
                              //                 "",
                              //           ));
                              //         },
                              //         child: Stack(
                              //           children: [
                              //             Container(
                              //               height: 100,
                              //               width: 100,
                              //               margin: EdgeInsets.only(
                              //                   left: 8,
                              //                   right: 8,
                              //                   bottom: 8),
                              //               child: ClipRRect(
                              //                 borderRadius:
                              //                 BorderRadius
                              //                     .circular(15),
                              //                 child: FadeInImage
                              //                     .assetNetwork(
                              //                   placeholder:
                              //                   "assets/ezgif.com-crop.gif",
                              //                   placeholderCacheHeight:
                              //                   100,
                              //                   placeholderCacheWidth:
                              //                   100,
                              //                   placeholderFit:
                              //                   BoxFit.cover,
                              //                   image: YoutubePlayer.getThumbnail(
                              //                     videoId: YoutubePlayer.convertUrlToId(eventDetailsController.eventInfo?.eventData.eventVideoUrls[index] ?? "")!,
                              //                   ),
                              //                   fit: BoxFit.cover,
                              //                 ),
                              //               ),
                              //               decoration:
                              //               BoxDecoration(
                              //                 borderRadius:
                              //                 BorderRadius
                              //                     .circular(15),
                              //                 color: Colors.white,
                              //                 boxShadow: [
                              //                   BoxShadow(
                              //                     color: Colors.grey
                              //                         .shade300,
                              //                     offset:
                              //                     const Offset(
                              //                       0.5,
                              //                       0.5,
                              //                     ),
                              //                     blurRadius: 0.5,
                              //                     spreadRadius: 0.5,
                              //                   ), //BoxShadow
                              //                   BoxShadow(
                              //                     color:
                              //                     Colors.white,
                              //                     offset:
                              //                     const Offset(
                              //                         0.0, 0.0),
                              //                     blurRadius: 0.0,
                              //                     spreadRadius: 0.0,
                              //                   ), //BoxShadow
                              //                 ],
                              //               ),
                              //             ),
                              //             Positioned(
                              //               top: 35,
                              //               left: 35,
                              //               right: 35,
                              //               bottom: 35,
                              //               child: Image.asset(
                              //                 "assets/videopush.png",
                              //                 height: 20,
                              //                 width: 20,
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       )
                              //           : SizedBox();
                              //     },
                              //   ),
                              // )
                              //     :
                              //     SizedBox(),



                              bookStatus == "2"
                                  ? eventDetailsController
                                          .eventInfo!.reviewdata.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Text(
                                            "Review".tr,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: BlackColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : SizedBox()
                                  : SizedBox(),
                              bookStatus == "2"
                                  ? eventDetailsController.eventInfo!.reviewdata.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: eventDetailsController.eventInfo?.reviewdata.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                top: index == 0 ? 3 : 5,
                                                left: 8,
                                                right: 8,
                                                bottom: 8,
                                              ),
                                              child: ListTile(
                                                leading: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder:
                                                          "assets/ezgif.com-crop.gif",
                                                      height: 50,
                                                      width: 50,
                                                      image:
                                                          "${Config.imageUrl}${eventDetailsController.eventInfo?.reviewdata[index].userImg ?? ""}",
                                                      placeholderFit:
                                                          BoxFit.cover,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                title: Text(
                                                  eventDetailsController
                                                          .eventInfo
                                                          ?.reviewdata[index]
                                                          .customername ??
                                                      "",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    color: BlackColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${eventDetailsController.eventInfo?.reviewdata[index].rateText ?? ""}",
                                                  textAlign: TextAlign.start,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color: greytext,
                                                    fontFamily:
                                                        FontFamily.gilroyMedium,
                                                  ),
                                                ),
                                                trailing: Container(
                                                  height: 40,
                                                  width: 70,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: gradient
                                                            .defoultColor,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        "${eventDetailsController.eventInfo?.reviewdata[index].rateNumber ?? ""}",
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .gilroyBold,
                                                          color: gradient
                                                              .defoultColor,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          gradient.defoultColor,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: WhiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox()
                                  : SizedBox(),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Text(
                                  "Maps".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: BlackColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                height: 130,
                                width: Get.size.width,
                                margin: EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                          double.parse(eventDetailsController
                                                  .eventInfo
                                                  ?.eventData
                                                  .eventLatitude ??
                                              "0"),
                                          double.parse(eventDetailsController
                                                  .eventInfo
                                                  ?.eventData
                                                  .eventLongtitude ??
                                              "0")), //initial position
                                      zoom: 10.0, //initial zoom level
                                    ),
                                    markers: Set<Marker>.of(_markers),
                                    mapType: MapType.normal,
                                    myLocationEnabled: true,
                                    compassEnabled: true,
                                    zoomGesturesEnabled: true,
                                    tiltGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    onMapCreated: (controller) {
                                      setState(() {
                                        mapController = controller;
                                      });
                                    },
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              eventDetailsController.eventInfo!.eventData.eventTags.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventData.eventTags.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                        "Tags".tr,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          color: BlackColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventData.eventTags.isNotEmpty
                                  ? SizedBox(
                                      height: 10,
                                    )
                                  : SizedBox(),
                              eventDetailsController.eventInfo!.eventData.eventTags.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Wrap(
                                        spacing: 5.0,
                                        runSpacing: 0,
                                        children: List<Widget>.generate(
                                            eventDetailsController
                                                .eventInfo!
                                                .eventData
                                                .eventTags
                                                .length, (int index) {
                                          return InkWell(
                                            onTap: () {},
                                            child: Chip(
                                              padding: EdgeInsets.zero,
                                              labelPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              backgroundColor: gradient
                                                  .defoultColor
                                                  .withOpacity(0.9),
                                              label: Text(
                                                eventDetailsController
                                                    .eventInfo!
                                                    .eventData
                                                    .eventTags[index],
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 12,
                                                  color: WhiteColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      }),
    );
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

}
