// ignore_for_file: file_names, prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables, deprecated_member_use, unused_field, sort_child_properties_last, sized_box_for_whitespace, unnecessary_brace_in_string_interps, must_be_immutable, unnecessary_string_interpolations

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:magicmate_organizer/Dashboard/Qr%20View/qrview_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/eventdetails_controller.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/dark_light_mode.dart';

class EventDetailsScreen extends StatefulWidget {
  String? status;
  EventDetailsScreen({this.status, super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventDetailsController eventDetailsController = Get.find();

  int currentindex = 0;
  List<String> jobdetails = [
    "Event Info",
    "Join",
    "Attended",
    "Not Going",
    "Artist",
    "Review",
  ];

  bool _pinned = true;
  bool _snap = false;
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = Get.size.height * 0.25;
  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    getDarkMode();
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }


  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      bottomNavigationBar: widget.status == "Today event"
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  eventDetailsController.eventInfo!.eventdata!.attendUser!.isNotEmpty
                      ? Expanded(
                          child: InkWell(
                            onTap: () {
                              eventDetailsController.eventCompletedApi(
                                eventId: eventDetailsController
                                        .eventInfo?.eventdata!.eventId ??
                                    "",
                              );
                            },
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.only(left: 5),
                              alignment: Alignment.center,
                              child: Text(
                                "Completed",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  color: WhiteColor,
                                  fontSize: 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                gradient: gradient.completeGradient,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: AppButton(
                            // buttonColor: ,
                            gradientcolor: gradient.cancleGradient,
                            buttontext: "Cancelled",
                            textcolor: WhiteColor,
                            margin1: EdgeInsets.only(right: 5),
                            onTap: () {
                              cancelSheet();
                            },
                          ),
                        ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(QrViewScreen());
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(left: 5),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "CheckIn",
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: WhiteColor,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              "assets/QRcodescan.png",
                              height: 20,
                              width: 20,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: appcolor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(),
      body: GetBuilder<EventDetailsController>(builder: (context) {
        return eventDetailsController.isLoading
            ? CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: notifier.background,
                    // floating: true,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    // snap: true,
                    pinned: _pinned,
                    expandedHeight: Get.height * 0.30,
                    centerTitle: true,
                    // title: _isShrink
                    //     ? Column(
                    //         children: [
                    //           Text("Blockchain Architect",
                    //               style: TextStyle(
                    //                   fontFamily: FontFamily.gilroyBold,
                    //                   color: BlackColor,
                    //                   fontSize: 16)),
                    //           SizedBox(height: Get.height * 0.001),
                    //           Text("Crypto.com",
                    //               style: TextStyle(
                    //                   fontFamily: FontFamily.gilroyMedium,
                    //                   color: greyColor2,
                    //                   fontSize: 16)),
                    //         ],
                    //       )
                    //     : null,
                    leading: Padding(
                      padding: const EdgeInsets.all(19),
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset("assets/leftarrow.png",color: notifier.textColor,),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size(double.infinity, 75),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: SizedBox(
                          height: 50,
                          // color: BlackColor,
                          width: double.infinity,
                          child: ListView.separated(
                            itemCount: widget.status == "Today event"
                                ? jobdetails.length - 1
                                : jobdetails.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    currentindex = index;
                                  });
                                },
                                child: Container(
                                  // width: Get.width * 0.3,
                                  height: 8,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: currentindex == index
                                          ? appcolor
                                          : notifier.background,
                                      border: Border.all(
                                          color: Greycolor.withOpacity(0.3))),
                                  child: Text(jobdetails[index],
                                      style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          color: currentindex == index
                                              ? WhiteColor
                                              : notifier.textColor,
                                          fontSize: 16)),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(width: Get.width * 0.03),
                          ),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            SizedBox(height: Get.height * 0.11),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              width: Get.size.width,
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.network(
                                            "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata!.eventImage ?? ""}",
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.56,
                                              child: Text(
                                                eventDetailsController
                                                        .eventInfo
                                                        ?.eventdata
                                                        !.eventTitle ??
                                                    "",
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  color: notifier.textColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        eventDetailsController.eventInfo
                                                ?.eventdata!.eventStartDate
                                                .toString()
                                                .split(" ")
                                                .first ??
                                            "",
                                        // mymedicine
                                        //         .medicinedata
                                        //         ?.medicinedata[index]
                                        //         .catName ??
                                        //     "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: greycolor,
                                            fontFamily: FontFamily.gilroyMedium,
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/mappin.png",
                                            height: 20,
                                            width: 20,
                                            color: appcolor,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          SizedBox(
                                            width: Get.size.width * 0.49,
                                            child: Text(
                                              "${eventDetailsController.eventInfo?.eventdata!.eventPlaceName}",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
                                                color: greycolor,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: notifier.border),
                                color: notifier.background,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        currentindex == 0
                            ? eventInfo()
                            : currentindex == 1
                                ? eventJoinList()
                                : currentindex == 2
                                    ? eventAttendedList()
                                    : currentindex == 3
                                        ? eventNotGoingList()
                                        : currentindex == 4
                                            ? eventArtistList()
                                            : currentindex == 5
                                                ? reviewList()
                                                : SizedBox(),
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

  companyDetails({String? image, title, subtitle}) {
    return Column(
      children: [
        Image.asset(image!, height: 25, width: 25),
        SizedBox(height: Get.height * 0.01),
        Text(
          title,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            color: greyColor2,
            fontSize: 15,
          ),
        ),
        SizedBox(height: Get.height * 0.005),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  eventInfo() {
    return Container(
      height: Get.size.height,
      width: Get.size.width,
      color: notifier.background,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "Event Info",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 15,
              color: notifier.textColor,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          eventDetailsController.eventInfo?.eventdata!.eventTypeList != "null"
              ? eventInfoRow(
                  image: "assets/global.png",
                  title: "Ticket Type",
                  value: eventDetailsController
                          .eventInfo?.eventdata!.eventTypeList ??
                      "",
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
          eventInfoRow(
            image: "assets/mappin.png",
            title: "Location",
            value:
                eventDetailsController.eventInfo?.eventdata!.eventAddress ?? "",
          ),
          SizedBox(
            height: 10,
          ),
          eventInfoRow(
            image: "assets/flash.png",
            title: "Joined",
            value: eventDetailsController.eventInfo?.eventdata!.totalBookTicket
                    .toString() ??
                "",
          ),
          SizedBox(
            height: 10,
          ),
          eventInfoRow(
            image: "assets/companygroup.png",
            title: "Total Spots",
            value: eventDetailsController.eventInfo?.eventdata!.totalTicket
                    .toString() ??
                "",
          ),
          SizedBox(
            height: 10,
          ),
          eventInfoRow(
            image: "assets/trend-up-circle.png",
            title: "Revenue",
            value:
                "${currency}${eventDetailsController.eventInfo?.eventdata!.eventRevnue}",
          ),
          SizedBox(
            height: 10,
          ),
          eventInfoRow(
            image: "assets/dollarcircle.png",
            title: "Ticket Price",
            value:
                eventDetailsController.eventInfo?.eventdata!.ticketPrice ?? "",
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Description",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 17,
              color: notifier.textColor,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          HtmlWidget(
            eventDetailsController.eventInfo?.eventdata!.eventDescription ?? "",
            textStyle: TextStyle(
              color: notifier.textColor,
              fontSize: 12,
              // fontSize: Get.height / 50,
              fontFamily: 'Gilroy Normal',
            ),
          ),
        ],
      ),
    );
  }

  eventInfoRow({String? image, title, value}) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Image.asset(
                image ?? "",
                height: 25,
                width: 25,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 14,
                  color: notifier.textColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: Get.size.width * 0.5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              color: notifier.textColor,
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    );
  }

  eventJoinList() {
    return eventDetailsController.eventInfo!.eventdata!.joinedUser!.isNotEmpty
        ? ListView.builder(
            itemCount: eventDetailsController.eventInfo?.eventdata!.joinedUser!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                width: Get.size.width,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FadeInImage.assetNetwork(
                          placeholderCacheHeight: 45,
                          placeholderCacheWidth: 45,
                          placeholderFit: BoxFit.cover,
                          height: 45,
                          width: 45,
                          placeholder: "assets/ezgif.com-crop.gif",
                          image:
                              "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata!.joinedUser![index].userImg ?? ""}",
                          fit: BoxFit.cover,
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: notifier.textColor,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetailsController.eventInfo?.eventdata!.joinedUser![index].customername ??
                                "",
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                              color: notifier.textColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.joinedUser![index].totalTicketPurchase ?? ""}x",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.joinedUser![index].totalType ?? ""}",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        var url = Uri.parse(
                            "tel:${eventDetailsController.eventInfo?.eventdata!.joinedUser![index].customermobile ?? ""}");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/phone.png",
                          color: notifier.textColor,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifier.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          )
        : Column(
            children: [
              SizedBox(
                height: Get.size.height * 0.3,
              ),
              Center(
                child: Text(
                  "Join User Not Available",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
  }

  eventAttendedList() {
    return eventDetailsController.eventInfo!.eventdata!.attendUser!.isNotEmpty
        ? ListView.builder(
            itemCount:
                eventDetailsController.eventInfo?.eventdata!.attendUser!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                width: Get.size.width,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/ezgif.com-crop.gif",
                          height: 45,
                          width: 45,
                          placeholderCacheHeight: 45,
                          placeholderCacheWidth: 45,
                          fit: BoxFit.cover,
                          image:
                              "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata!.attendUser![index].userImg}",
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: notifier.textColor,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetailsController.eventInfo?.eventdata
                            !.attendUser![index].customername ??
                                "",
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                              color: notifier.textColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.attendUser![index].totalTicketPurchase ?? ""}x",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.attendUser![index].totalType ?? ""}",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      child: Image.asset("assets/phone.png",
                          color: notifier.textColor,
                          height: 25, width: 25),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifier.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          )
        : Column(
            children: [
              SizedBox(
                height: Get.size.height * 0.3,
              ),
              Center(
                child: Text(
                  "User Not Available",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
  }

  eventNotGoingList() {
    return eventDetailsController.eventInfo!.eventdata!.notjoinedUser!.isNotEmpty
        ? ListView.builder(
            itemCount: eventDetailsController
                .eventInfo?.eventdata!.notjoinedUser!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                width: Get.size.width,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/ezgif.com-crop.gif",
                          height: 45,
                          width: 45,
                          image:
                              "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata!.notjoinedUser![index].userImg ?? ""}",
                          placeholderCacheHeight: 45,
                          placeholderCacheWidth: 45,
                          fit: BoxFit.cover,
                          placeholderFit: BoxFit.fill,
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BlackColor,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetailsController.eventInfo?.eventdata
                            !.notjoinedUser![index].customername ??
                                "",
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                              color: notifier.textColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.notjoinedUser![index].totalTicketPurchase ?? ""}x",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${eventDetailsController.eventInfo?.eventdata!.notjoinedUser![index].totalType ?? ""}",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 13,
                                  color: greycolor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        var url = Uri.parse(
                            "tel:${eventDetailsController.eventInfo?.eventdata!.notjoinedUser![index].customermobile ?? ""}");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/phone.png",
                          height: 25,
                          width: 25,
                          color: notifier.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifier.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          )
        : Column(
            children: [
              SizedBox(
                height: Get.size.height * 0.3,
              ),
              Center(
                child: Text(
                  "User Not Available",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
  }

  eventArtistList() {
    return eventDetailsController.eventInfo!.eventdata!.artistdata!.isNotEmpty
        ? ListView.builder(
            itemCount:
                eventDetailsController.eventInfo?.eventdata!.artistdata!.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 75,
                width: Get.size.width,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/ezgif.com-crop.gif",
                          height: 60,
                          width: 60,
                          placeholderCacheHeight: 60,
                          placeholderCacheWidth: 60,
                          image:
                              "${AppUrl.imageurl}${eventDetailsController.eventInfo!.eventdata!.artistdata![index].artistImg}",
                          fit: BoxFit.cover,
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetailsController.eventInfo?.eventdata
                            !.artistdata![index].artistTitle ??
                                "",
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            eventDetailsController.eventInfo?.eventdata
                            !.artistdata![index].artistRole ??
                                "",
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 14,
                              color: greycolor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifier.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          )
        : Column(
            children: [
              SizedBox(
                height: Get.size.height * 0.3,
              ),
              Center(
                child: Text(
                  "Artist Not Available",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
  }

  reviewList() {
    return eventDetailsController.eventInfo!.eventdata!.totalReview!.isNotEmpty
        ? ListView.builder(
            itemCount:
                eventDetailsController.eventInfo?.eventdata!.totalReview!.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // return Container(
              //   margin: EdgeInsets.all(8),
              //   padding: EdgeInsets.all(8),
              //   child: ListTile(
              //     leading: Container(
              //       height: 50,
              //       width: 50,
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(40),
              //         child: FadeInImage.assetNetwork(
              //           placeholder: "assets/ezgif.com-crop.gif",
              //           height: 50,
              //           width: 50,
              //           image:
              //               "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata.totalReview[index].userImg ?? ""}",
              //           placeholderFit: BoxFit.cover,
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //       decoration: BoxDecoration(
              //         border: Border.all(color: Colors.grey.shade200),
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     title: Text(
              //       eventDetailsController.eventInfo?.eventdata
              //               .totalReview[index].customername ??
              //           "",
              //       style: TextStyle(
              //         fontFamily: FontFamily.gilroyBold,
              //         color: BlackColor,
              //         fontSize: 15,
              //       ),
              //     ),
              //     subtitle: Text(
              //       "${eventDetailsController.eventInfo?.eventdata.totalReview[index].rateText ?? ""}",
              //       textAlign: TextAlign.start,
              //       maxLines: 2,
              //       style: TextStyle(
              //         color: greycolor,
              //         fontFamily: FontFamily.gilroyMedium,
              //       ),
              //     ),
              //     trailing: Container(
              //       height: 40,
              //       width: 70,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(
              //             Icons.star,
              //             color: gradient.defoultColor,
              //           ),
              //           SizedBox(
              //             width: 5,
              //           ),
              //           Text(
              //             "${eventDetailsController.eventInfo?.eventdata.totalReview[index].rateNumber ?? ""}",
              //             style: TextStyle(
              //               fontFamily: FontFamily.gilroyBold,
              //               color: gradient.defoultColor,
              //             ),
              //           )
              //         ],
              //       ),
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: gradient.defoultColor,
              //           width: 2,
              //         ),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //     ),
              //   ),
              //   decoration: BoxDecoration(
              //     color: WhiteColor,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              // );

              return Container(
                height: 70,
                width: Get.size.width,
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/ezgif.com-crop.gif",
                          image:
                              "${AppUrl.imageurl}${eventDetailsController.eventInfo?.eventdata!.totalReview![index].userImg ?? ""}",
                          height: 50,
                          width: 50,
                          placeholderCacheHeight: 50,
                          placeholderCacheWidth: 50,
                          placeholderFit: BoxFit.cover,
                          fit: BoxFit.cover,
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetailsController.eventInfo?.eventdata!.totalReview![index].customername ?? "",
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: notifier.textColor,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "${eventDetailsController.eventInfo?.eventdata!.totalReview![index].rateText ?? ""}",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            style: TextStyle(
                              color: greycolor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      height: 40,
                      width: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: gradient.defoultColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${eventDetailsController.eventInfo?.eventdata!.totalReview![index].rateNumber ?? ""}",
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: gradient.defoultColor,
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: gradient.defoultColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifier.containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          )
        : Column(
            children: [
              SizedBox(
                height: Get.size.height * 0.3,
              ),
              Center(
                child: Text(
                  "Review Not Available",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
  }

  Future cancelSheet() {
    return Get.bottomSheet(
      Container(
        height: 220,
        width: Get.size.width,
        decoration: BoxDecoration(
          color: notifier.containerColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Cancel Event".tr,
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.gilroyBold,
                  color: RedColor),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: greycolor),
            ),
            SizedBox(height: 10),
            Text(
              "Are you sure you want to cancle event?".tr,
              style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 16,
                  color: notifier.textColor),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(
                            color: notifier.buttonText,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                        color: notifier.button,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      eventDetailsController.eventCancleApi(
                        eventId: eventDetailsController
                                .eventInfo?.eventdata!.eventId ??
                            "",
                      );
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Confirm".tr,
                        style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                          gradient: gradient.btnGradient,
                          borderRadius: BorderRadius.circular(45)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
