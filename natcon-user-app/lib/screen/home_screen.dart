// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, sized_box_for_whitespace, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magicmate_user/screen/profile/notification_screen.dart';
import 'package:magicmate_user/screen/searchevent_screen.dart';
import 'package:magicmate_user/screen/seeAll/latest_event.dart';
import 'package:magicmate_user/screen/seeAll/upcoming_event.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../firebase_accesstoken.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import 'LoginAndSignup/login_screen.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

var currency;
var wallet1;

class _HomeScreenState extends State<HomeScreen> {
  HomePageController homePageController = Get.find();
  EventDetailsController eventDetailsController = Get.find();
  LoginController loginController = Get.find();
  String? networkimage;
  String userName = "";
  String? base64Image;

  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = Get.height * 0.25;

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
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    getData.read("UserLogin") != null
        ? setState(() {
            userName = getData.read("UserLogin")["name"] ?? "";
            networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
            getData.read("UserLogin")["pro_pic"] != "null"
                ? setState(() {
                    networkimageconvert();
                  })
                : const SizedBox();
          })
        : null;
  }

  networkimageconvert() {
    (() async {
      http.Response response =
          await NatconHttp.get(Uri.parse(Config.imageUrl + networkimage.toString()));
      if (mounted) {
        print(response.bodyBytes);
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: GetBuilder<HomePageController>(builder: (homePageController) {
        return SafeArea(
          child: homePageController.isLoading
              ? NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        elevation: 0,
                        pinned: true,
                        expandedHeight: Get.size.height * 0.34,
                        titleSpacing: 0,
                        backgroundColor:
                            _isShrink ? gradient.defoultColor : transparent,
                        leading: Padding(
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/homelogo.png",
                            height: 20,
                            width: 30,
                          ),
                        ),
                        title: Text(
                          "MagicMate".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 20,
                            color: WhiteColor,
                          ),
                        ),
                        actions: [
                          InkWell(
                            onTap: () {
                              if (getData.read("UserLogin") != null) {
                                Get.to(NotificationScreen());
                              } else {
                                Get.to(() => LoginScreen());
                              }
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/Notification.png",
                                height: 20,
                                width: 20,
                                color: gradient.defoultColor,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: WhiteColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            // height: Get.size.height * 0.38,
                            width: Get.size.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 45,
                                  ),
                                  SizedBox(
                                    height: Get.size.height * 0.020,
                                  ),
                                  Text(
                                    "Discover amazing event\nnear by you.".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 22,
                                      color: WhiteColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: Get.size.height * 0.040,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(SearchEventScreen());
                                    },
                                    child: Container(
                                      height: 45,
                                      width: Get.size.width,
                                      margin: EdgeInsets.only(right: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Image.asset(
                                            "assets/Search.png",
                                            height: 25,
                                            width: 25,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "Search...".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: WhiteColor,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Get.size.height * 0.025,
                                  ),
                                  Container(
                                    height: 35,
                                    width: Get.size.width,
                                    alignment: Alignment.center,
                                    child:
                                    homePageController.homeInfo!.homeData.catlist.isNotEmpty
                                        ? ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                        width: 10,
                                      ),
                                      itemCount: homePageController.homeInfo!.homeData.catlist.length,
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            eventDetailsController.getCatWiseEvent(
                                              catId: homePageController.homeInfo?.homeData.catlist[index].id,
                                              title: homePageController.homeInfo?.homeData.catlist[index].title ?? "",
                                              img: homePageController.homeInfo?.homeData.catlist[index].coverImg ?? "",
                                            );
                                          },
                                          child: Container(
                                            height: 30,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            // margin: EdgeInsets.symmetric(horizontal: 8),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  "${Config.imageUrl}${homePageController.homeInfo?.homeData.catlist[index].catImg}",
                                                  height: 20,
                                                  width: 20,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  homePageController
                                                          .homeInfo
                                                          ?.homeData
                                                          .catlist[index]
                                                          .title ??
                                                      "",
                                                  style: TextStyle(
                                                      color: BlackColor,
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              color: WhiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "No Nearby Event placed!",
                                            style: TextStyle(
                                                fontFamily: FontFamily.gilroyBold,
                                                color: WhiteColor,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              image: DecorationImage(
                                image: AssetImage("assets/Backgound.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: RefreshIndicator(
                    color: gradient.defoultColor,
                    onRefresh: () {
                      return Future.delayed(
                        Duration(seconds: 2),
                        () {
                          homePageController.getHomeDataApi();
                        },
                      );
                    },
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Latest Event".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Get.to(LatestEvent(eventStaus: "1"));
                                    },
                                    child: Text(
                                      "See All".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        homePageController.homeInfo!.homeData.latestEvent.isNotEmpty
                            ? SizedBox(
                                height: 320,
                                width: Get.size.width,
                                child: ListView.builder(
                                  itemCount: homePageController
                                      .homeInfo?.homeData.latestEvent.length
                                      .clamp(0, 5),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        await eventDetailsController
                                            .getEventData(
                                          eventId: homePageController
                                              .homeInfo
                                              ?.homeData
                                              .latestEvent[index]
                                              .eventId,
                                        );
                                        Get.toNamed(
                                          Routes.eventDetailsScreen,
                                          arguments: {
                                            "eventId": homePageController
                                                .homeInfo
                                                ?.homeData
                                                .latestEvent[index]
                                                .eventId,
                                            "bookStatus": "1"
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 320,
                                        width: 240,
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                height: 320,
                                                width: 240,
                                                child: FadeInImage.assetNetwork(
                                                  fadeInCurve:
                                                      Curves.easeInCirc,
                                                  placeholder:
                                                      "assets/ezgif.com-crop.gif",
                                                  height: 320,
                                                  width: 240,
                                                  placeholderCacheHeight: 320,
                                                  placeholderCacheWidth: 240,
                                                  placeholderFit: BoxFit.fill,
                                                  // placeholderScale: 1.0,
                                                  image:
                                                      "${Config.imageUrl}${homePageController.homeInfo?.homeData.latestEvent[index].eventImg}",
                                                  fit: BoxFit.cover,
                                                ),

                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    stops: [0.6, 0.8, 1.5],
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black
                                                          .withOpacity(0.5),
                                                      Colors.black
                                                          .withOpacity(0.5),
                                                    ],
                                                  ),
                                                  //border: Border.all(color: lightgrey),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 5,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          bottom: 5,
                                                          right: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 240,
                                                        child: Text(
                                                          homePageController
                                                                  .homeInfo
                                                                  ?.homeData
                                                                  .latestEvent[
                                                                      index]
                                                                  .eventTitle ??
                                                              "",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                            fontSize: 17,
                                                            color: WhiteColor,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        homePageController
                                                                .homeInfo
                                                                ?.homeData
                                                                .latestEvent[
                                                                    index]
                                                                .eventSdate ??
                                                            "",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                          color: WhiteColor,
                                                          fontSize: 15,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            "assets/Location.png",
                                                            color: WhiteColor,
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          SizedBox(
                                                            width: 210,
                                                            child: Text(
                                                              homePageController
                                                                      .homeInfo
                                                                      ?.homeData
                                                                      .latestEvent[
                                                                          index]
                                                                      .eventPlaceName ??
                                                                  "",
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontFamily
                                                                        .gilroyMedium,
                                                                fontSize: 15,
                                                                color:
                                                                    WhiteColor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: WhiteColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 150,
                                width: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/emptyOrder.png")),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Latest Event placed!",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: BlackColor,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Currently you don’t have any Latest Event.",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: greyColor),
                              ),
                            ],
                          ),
                        ),
                        Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Nearby Event".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Get.to(LatestEvent(eventStaus: "3"));
                                    },
                                    child: Text(
                                      "See All".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        homePageController.homeInfo!.homeData.nearbyEvent.isNotEmpty
                            ? Container(
                                height: Get.height * 0.34,
                                width: Get.size.width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: homePageController
                                      .homeInfo?.homeData.nearbyEvent.length
                                      .clamp(0, 5),
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        await eventDetailsController.getEventData(
                                          eventId: homePageController.homeInfo?.homeData.nearbyEvent[index].eventId,
                                        );
                                        Get.toNamed(
                                          Routes.eventDetailsScreen,
                                          arguments: {
                                            "eventId": homePageController.homeInfo?.homeData.nearbyEvent[index].eventId,
                                            "bookStatus": "1",
                                          },
                                        );
                                      },
                                      child: Container(
                                        // height: Get.height * 0.37,
                                        width: Get.width / 1.5,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              height: Get.height / 4.9,
                                              width: Get.width / 1.4,
                                              margin: EdgeInsets.all(5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "assets/ezgif.com-crop.gif",
                                                  height: Get.height / 4.9,
                                                  width: Get.width / 1.4,
                                                  image:
                                                      "${Config.imageUrl}${homePageController.homeInfo?.homeData.nearbyEvent[index].eventImg ?? ""}",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 65,
                                              width: Get.size.width,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          homePageController.homeInfo?.homeData.nearbyEvent[index].eventTitle ?? "",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            color: BlackColor,
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                            fontSize: 15,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              "assets/Location.png",
                                                              color: BlackColor,
                                                              height: 15,
                                                              width: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            SizedBox(
                                                              width: Get.size.width * 0.54,
                                                              child: Text(
                                                                homePageController.homeInfo?.homeData.nearbyEvent[index].eventPlaceName ??
                                                                    "",
                                                                maxLines: 1,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .gilroyMedium,
                                                                  fontSize: 15,
                                                                  color:
                                                                      BlackColor,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Divider(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    homePageController.homeInfo?.homeData.nearbyEvent[index].eventSdate ?? "",
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      color: greytext,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          color: WhiteColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 150,
                                width: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/emptyOrder.png")),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Nearby Event placed!",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: BlackColor,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Currently you don’t have any Nearby Event.",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: greyColor),
                              ),
                            ],
                          ),
                        ),
                        Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Monthly Event".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Get.to(LatestEvent(eventStaus: "2"));
                                    },
                                    child: Text(
                                      "See All".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        homePageController.homeInfo!.homeData.thisMonthEvent.isNotEmpty
                            ? SizedBox(
                                height: Get.height * 0.34,
                                width: Get.size.width,
                                child: ListView.builder(
                                  itemCount: homePageController
                                      .homeInfo?.homeData.thisMonthEvent.length
                                      .clamp(0, 5),
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        await eventDetailsController.getEventData(
                                          eventId: homePageController.homeInfo?.homeData.thisMonthEvent[index].eventId,
                                        );
                                        Get.toNamed(
                                          Routes.eventDetailsScreen,
                                          arguments: {
                                            "eventId": homePageController
                                                .homeInfo
                                                ?.homeData
                                                .thisMonthEvent[index]
                                                .eventId,
                                            "bookStatus": "1",
                                          },
                                        );
                                      },
                                      child: Container(
                                        // height: Get.height * 0.37,
                                        width: Get.width / 1.5,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: Get.height / 4.9,
                                              width: Get.width / 1.4,
                                              margin: EdgeInsets.all(5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "assets/ezgif.com-crop.gif",
                                                  height: Get.height / 4.9,
                                                  width: Get.width / 1.4,
                                                  image:
                                                      "${Config.imageUrl}${homePageController.homeInfo?.homeData.thisMonthEvent[index].eventImg ?? ""}",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 65,
                                              width: Get.size.width,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          homePageController.homeInfo?.homeData.thisMonthEvent[index].eventTitle ?? "",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            color: BlackColor,
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                            fontSize: 15,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              "assets/Location.png",
                                                              color: BlackColor,
                                                              height: 15,
                                                              width: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            SizedBox(
                                                              width: Get.size.width * 0.54,
                                                              child: Text(
                                                                homePageController.homeInfo?.homeData.thisMonthEvent[index].eventPlaceName ?? "",
                                                                maxLines: 1,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .gilroyMedium,
                                                                  fontSize: 15,
                                                                  color:
                                                                      BlackColor,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Divider(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    homePageController
                                                            .homeInfo
                                                            ?.homeData
                                                            .thisMonthEvent[
                                                                index]
                                                            .eventSdate ??
                                                        "",
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      color: greytext,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          color: WhiteColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 150,
                                width: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/emptyOrder.png")),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Monthly Event placed!",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: BlackColor,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Currently you don’t have any Monthly Event.",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: greyColor),
                              ),
                            ],
                          ),
                        ),
                        Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Upcoming Event".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: BlackColor,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Get.to(UpComingEvent());
                                    },
                                    child: Text(
                                      "See All".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                        homePageController.homeInfo!.homeData.upcomingEvent.isNotEmpty
                            ? ListView.builder(
                                itemCount: homePageController
                                    .homeInfo?.homeData.upcomingEvent.length
                                    .clamp(0, 5),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () async {
                                      await eventDetailsController.getEventData(
                                        eventId: homePageController
                                            .homeInfo
                                            ?.homeData
                                            .upcomingEvent[index]
                                            .eventId,
                                      );
                                      Get.toNamed(
                                        Routes.eventDetailsScreen,
                                        arguments: {
                                          "eventId": homePageController
                                              .homeInfo
                                              ?.homeData
                                              .upcomingEvent[index]
                                              .eventId,
                                          "bookStatus": "1",
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 120,
                                      width: Get.size.width,
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          bottom: 10,
                                          top: index == 0 ? 0 : 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 100,
                                            margin: EdgeInsets.all(8),
                                            alignment: Alignment.center,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    "assets/ezgif.com-crop.gif",
                                                height: 120,
                                                width: 100,
                                                placeholderCacheHeight: 120,
                                                placeholderCacheWidth: 100,
                                                image:
                                                    "${Config.imageUrl}${homePageController.homeInfo?.homeData.upcomingEvent[index].eventImg}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        homePageController
                                                                .homeInfo
                                                                ?.homeData
                                                                .upcomingEvent[
                                                                    index]
                                                                .eventTitle ??
                                                            "",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .gilroyBold,
                                                          fontSize: 15,
                                                          color: BlackColor,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        homePageController
                                                                .homeInfo
                                                                ?.homeData
                                                                .upcomingEvent[
                                                                    index]
                                                                .eventSdate ??
                                                            "",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                          fontSize: 14,
                                                          color: greytext,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      "assets/Location.png",
                                                      color: BlackColor,
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          Get.size.width * 0.55,
                                                      child: Text(
                                                        homePageController
                                                                .homeInfo
                                                                ?.homeData
                                                                .upcomingEvent[
                                                                    index]
                                                                .eventPlaceName ??
                                                            "",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                          fontSize: 15,
                                                          color: BlackColor,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: WhiteColor,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 150,
                                width: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/emptyOrder.png")),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Upcoming Event placed!",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: BlackColor,
                                    fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Currently you don’t have any Upcoming Event.",
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: greyColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: gradient.defoultColor,
                  ),
                ),
        );
      }),
    );
    // return GetBuilder<HomePageController>(
    //   builder: (controller) {
    //     if (!controller.isLoading) {
    //       return CircularProgressIndicator();
    //     }
    //
    //     // if (controller.homeInfo == null || controller.markers.isEmpty) {
    //     //   return Center(
    //     //     child: Column(
    //     //       mainAxisAlignment: MainAxisAlignment.center,
    //     //       children: [
    //     //         Container(
    //     //           height: 150,
    //     //           width: 200,
    //     //           decoration: BoxDecoration(
    //     //             image: DecorationImage(
    //     //                 image: AssetImage("assets/emptyOrder.png")),
    //     //           ),
    //     //         ),
    //     //         SizedBox(
    //     //           height: 10,
    //     //         ),
    //     //         Text(
    //     //           "No Event placed!",
    //     //           style: TextStyle(
    //     //               fontFamily: FontFamily.gilroyBold,
    //     //               color: BlackColor,
    //     //               fontSize: 15),
    //     //         ),
    //     //         SizedBox(height: 5),
    //     //         Text(
    //     //           "Currently you don’t have any Event.",
    //     //           style: TextStyle(
    //     //               fontFamily: FontFamily.gilroyMedium,
    //     //               color: greyColor),
    //     //         ),
    //     //       ],
    //     //     ),
    //     //   );
    //     // }
    //
    //     return Scaffold(
    //       backgroundColor: bgcolor,
    //       body: NestedScrollView(
    //         controller: _scrollController,
    //         headerSliverBuilder: (context, innerBoxIsScrolled) {
    //           return [
    //             SliverAppBar(
    //               elevation: 0,
    //               pinned: true,
    //               expandedHeight: Get.size.height * 0.36,
    //               titleSpacing: 0,
    //               backgroundColor:
    //               _isShrink ? gradient.defoultColor : transparent,
    //               leading: Padding(
    //                 padding: EdgeInsets.all(12),
    //                 child: Image.asset(
    //                   "assets/homelogo.png",
    //                   height: 20,
    //                   width: 30,
    //                 ),
    //               ),
    //               title: Text(
    //                 "MagicMate".tr,
    //                 style: TextStyle(
    //                   fontFamily: FontFamily.gilroyBold,
    //                   fontSize: 20,
    //                   color: WhiteColor,
    //                 ),
    //               ),
    //               actions: [
    //                 InkWell(
    //                   onTap: () {
    //                     if (getData.read("UserLogin") != null) {
    //                       Get.to(NotificationScreen());
    //                     } else {
    //                       Get.to(() => LoginScreen());
    //                     }
    //                   },
    //                   child: Container(
    //                     height: 40,
    //                     width: 40,
    //                     alignment: Alignment.center,
    //                     child: Image.asset(
    //                       "assets/Notification.png",
    //                       height: 20,
    //                       width: 20,
    //                       color: gradient.defoultColor,
    //                     ),
    //                     decoration: BoxDecoration(
    //                       shape: BoxShape.circle,
    //                       color: WhiteColor,
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   width: 5,
    //                 ),
    //               ],
    //               flexibleSpace: FlexibleSpaceBar(
    //                 background: Container(
    //                   height: Get.size.height * 0.38,
    //                   width: Get.size.width,
    //                   child: Padding(
    //                     padding:
    //                     const EdgeInsets.symmetric(horizontal: 10),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         SizedBox(
    //                           height: 45,
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.020,
    //                         ),
    //                         Text(
    //                           "Discover amazing event\nnear by you.".tr,
    //                           style: TextStyle(
    //                             fontFamily: FontFamily.gilroyBold,
    //                             fontSize: 22,
    //                             color: WhiteColor,
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.040,
    //                         ),
    //                         InkWell(
    //                           onTap: () {
    //                             Get.to(SearchEventScreen());
    //                           },
    //                           child: Container(
    //                             height: 45,
    //                             width: Get.size.width,
    //                             margin: EdgeInsets.only(right: 10),
    //                             child: Row(
    //                               children: [
    //                                 SizedBox(
    //                                   width: 15,
    //                                 ),
    //                                 Image.asset(
    //                                   "assets/Search.png",
    //                                   height: 25,
    //                                   width: 25,
    //                                 ),
    //                                 SizedBox(
    //                                   width: 8,
    //                                 ),
    //                                 Text(
    //                                   "Search...".tr,
    //                                   style: TextStyle(
    //                                     fontFamily:
    //                                     FontFamily.gilroyMedium,
    //                                     color: Colors.grey.shade500,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                             decoration: BoxDecoration(
    //                               color: WhiteColor,
    //                               borderRadius: BorderRadius.circular(40),
    //                             ),
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: Get.size.height * 0.040,
    //                         ),
    //                         Container(
    //                           height: 35,
    //                           width: Get.size.width,
    //                           alignment: Alignment.center,
    //                           child: ListView.separated(
    //                             separatorBuilder: (context, index) =>
    //                                 SizedBox(
    //                                   width: 10,
    //                                 ),
    //                             itemCount: homePageController
    //                                 .homeInfo!.homeData.catlist.length,
    //                             scrollDirection: Axis.horizontal,
    //                             physics: BouncingScrollPhysics(),
    //                             padding: EdgeInsets.zero,
    //                             shrinkWrap: true,
    //                             itemBuilder: (context, index) {
    //                               return InkWell(
    //                                 onTap: () {
    //                                   eventDetailsController
    //                                       .getCatWiseEvent(
    //                                     catId: homePageController.homeInfo
    //                                         ?.homeData.catlist[index].id,
    //                                     title: homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .catlist[index]
    //                                         .title ??
    //                                         "",
    //                                     img: homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .catlist[index]
    //                                         .coverImg ??
    //                                         "",
    //                                   );
    //                                 },
    //                                 child: Container(
    //                                   height: 30,
    //                                   padding: EdgeInsets.symmetric(
    //                                       horizontal: 15),
    //                                   // margin: EdgeInsets.symmetric(horizontal: 8),
    //                                   alignment: Alignment.center,
    //                                   child: Row(
    //                                     children: [
    //                                       Image.network(
    //                                         "${Config.imageUrl}${homePageController.homeInfo?.homeData.catlist[index].catImg}",
    //                                         height: 20,
    //                                         width: 20,
    //                                       ),
    //                                       SizedBox(
    //                                         width: 4,
    //                                       ),
    //                                       Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .catlist[index]
    //                                             .title ??
    //                                             "",
    //                                         style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily: FontFamily
    //                                                 .gilroyMedium,
    //                                             fontSize: 15),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   decoration: BoxDecoration(
    //                                     color: WhiteColor,
    //                                     borderRadius:
    //                                     BorderRadius.circular(30),
    //                                   ),
    //                                 ),
    //                               );
    //                             },
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.only(
    //                       bottomLeft: Radius.circular(15),
    //                       bottomRight: Radius.circular(15),
    //                     ),
    //                     image: DecorationImage(
    //                       image: AssetImage("assets/Backgound.png"),
    //                       fit: BoxFit.cover,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ];
    //         },
    //         body: RefreshIndicator(
    //           color: gradient.defoultColor,
    //           onRefresh: () {
    //             return Future.delayed(
    //               Duration(seconds: 2),
    //                   () {
    //                 homePageController.getHomeDataApi();
    //               },
    //             );
    //           },
    //           child: ListView(
    //             shrinkWrap: true,
    //             padding: EdgeInsets.zero,
    //             physics: NeverScrollableScrollPhysics(),
    //             children: [
    //               homePageController.homeInfo!.homeData.latestEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Latest Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "1"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.latestEvent.isNotEmpty
    //                   ? SizedBox(
    //                 height: 320,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.latestEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   shrinkWrap: true,
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .latestEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .latestEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1"
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: 320,
    //                         width: 240,
    //                         margin: EdgeInsets.only(
    //                             left: 10, right: 10, bottom: 10),
    //                         child: ClipRRect(
    //                           borderRadius:
    //                           BorderRadius.circular(30),
    //                           child: Stack(
    //                             children: [
    //                               SizedBox(
    //                                 height: 320,
    //                                 width: 240,
    //                                 child: FadeInImage.assetNetwork(
    //                                   fadeInCurve:
    //                                   Curves.easeInCirc,
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: 320,
    //                                   width: 240,
    //                                   placeholderCacheHeight: 320,
    //                                   placeholderCacheWidth: 240,
    //                                   placeholderFit: BoxFit.fill,
    //                                   // placeholderScale: 1.0,
    //                                   image:
    //                                   "${Config.imageUrl}${homePageController.homeInfo?.homeData.latestEvent[index].eventImg}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //
    //                               ),
    //                               Container(
    //                                 decoration: BoxDecoration(
    //                                   gradient: LinearGradient(
    //                                     begin: Alignment.topCenter,
    //                                     end: Alignment.bottomCenter,
    //                                     stops: [0.6, 0.8, 1.5],
    //                                     colors: [
    //                                       Colors.transparent,
    //                                       Colors.black
    //                                           .withOpacity(0.5),
    //                                       Colors.black
    //                                           .withOpacity(0.5),
    //                                     ],
    //                                   ),
    //                                   //border: Border.all(color: lightgrey),
    //                                 ),
    //                               ),
    //                               Positioned(
    //                                 bottom: 5,
    //                                 child: Padding(
    //                                   padding:
    //                                   const EdgeInsets.only(
    //                                       left: 10,
    //                                       bottom: 5,
    //                                       right: 10),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                     CrossAxisAlignment
    //                                         .start,
    //                                     children: [
    //                                       SizedBox(
    //                                         width: 240,
    //                                         child: Text(
    //                                           homePageController
    //                                               .homeInfo
    //                                               ?.homeData
    //                                               .latestEvent[
    //                                           index]
    //                                               .eventTitle ??
    //                                               "",
    //                                           maxLines: 1,
    //                                           style: TextStyle(
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 17,
    //                                             color: WhiteColor,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                       SizedBox(
    //                                         height: 8,
    //                                       ),
    //                                       Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .latestEvent[
    //                                         index]
    //                                             .eventSdate ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           color: WhiteColor,
    //                                           fontSize: 15,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                       SizedBox(
    //                                         height: 5,
    //                                       ),
    //                                       Row(
    //                                         children: [
    //                                           Image.asset(
    //                                             "assets/Location.png",
    //                                             color: WhiteColor,
    //                                             height: 15,
    //                                             width: 15,
    //                                           ),
    //                                           SizedBox(
    //                                             width: 4,
    //                                           ),
    //                                           SizedBox(
    //                                             width: 210,
    //                                             child: Text(
    //                                               homePageController
    //                                                   .homeInfo
    //                                                   ?.homeData
    //                                                   .latestEvent[
    //                                               index]
    //                                                   .eventPlaceName ??
    //                                                   "",
    //                                               maxLines: 1,
    //                                               style: TextStyle(
    //                                                 fontFamily:
    //                                                 FontFamily
    //                                                     .gilroyMedium,
    //                                                 fontSize: 15,
    //                                                 color:
    //                                                 WhiteColor,
    //                                                 overflow:
    //                                                 TextOverflow
    //                                                     .ellipsis,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       )
    //                                     ],
    //                                   ),
    //                                 ),
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                         decoration: BoxDecoration(
    //                           borderRadius:
    //                           BorderRadius.circular(30),
    //                           color: WhiteColor,
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.nearbyEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Nearby Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "3"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.nearbyEvent.isNotEmpty
    //                   ? Container(
    //                 height: Get.height * 0.37,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   shrinkWrap: true,
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.nearbyEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   padding: EdgeInsets.zero,
    //                   physics: BouncingScrollPhysics(),
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .nearbyEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .nearbyEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1",
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: Get.height * 0.37,
    //                         width: Get.width / 1.5,
    //                         margin:
    //                         EdgeInsets.symmetric(horizontal: 8),
    //                         child: Column(
    //                           children: [
    //                             Container(
    //                               height: Get.height / 4.9,
    //                               width: Get.width / 1.4,
    //                               margin: EdgeInsets.all(5),
    //                               child: ClipRRect(
    //                                 borderRadius:
    //                                 BorderRadius.circular(20),
    //                                 child: FadeInImage.assetNetwork(
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: Get.height / 4.9,
    //                                   width: Get.width / 1.4,
    //                                   image:
    //                                   "${Config.imageUrl}${homePageController.homeInfo?.homeData.nearbyEvent[index].eventImg ?? ""}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //                               ),
    //                             ),
    //                             Container(
    //                               width: Get.size.width,
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: Column(
    //                                       mainAxisAlignment: MainAxisAlignment.center,
    //                                       crossAxisAlignment: CrossAxisAlignment.start,
    //                                       children: [
    //                                         Text(
    //                                           homePageController.homeInfo?.homeData.nearbyEvent[index].eventTitle ?? "",
    //                                           maxLines: 2,
    //                                           style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 15,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                           height: 4,
    //                                         ),
    //                                         Row(
    //                                           children: [
    //                                             Image.asset(
    //                                               "assets/Location.png",
    //                                               color: BlackColor,
    //                                               height: 15,
    //                                               width: 15,
    //                                             ),
    //                                             SizedBox(
    //                                               width: 4,
    //                                             ),
    //                                             SizedBox(
    //                                               width: Get.size.width * 0.54,
    //                                               child: Text(
    //                                                 homePageController.homeInfo?.homeData.nearbyEvent[index].eventPlaceName ??
    //                                                     "",
    //                                                 maxLines: 1,
    //                                                 style:
    //                                                 TextStyle(
    //                                                   fontFamily:
    //                                                   FontFamily
    //                                                       .gilroyMedium,
    //                                                   fontSize: 15,
    //                                                   color:
    //                                                   BlackColor,
    //                                                   overflow: TextOverflow.ellipsis,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         )
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 10),
    //                               child: Divider(
    //                                 color: Colors.grey.shade300,
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               height: 6,
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Text(
    //                                     homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .nearbyEvent[index]
    //                                         .eventSdate ??
    //                                         "",
    //                                     style: TextStyle(
    //                                       fontFamily: FontFamily
    //                                           .gilroyMedium,
    //                                       color: greytext,
    //                                       fontSize: 14,
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         ),
    //                         decoration: BoxDecoration(
    //                           color: WhiteColor,
    //                           borderRadius:
    //                           BorderRadius.circular(20),
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.thisMonthEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Monthly Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(LatestEvent(eventStaus: "2"));
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.thisMonthEvent.isNotEmpty
    //                   ? SizedBox(
    //                 height: Get.height * 0.37,
    //                 width: Get.size.width,
    //                 child: ListView.builder(
    //                   itemCount: homePageController
    //                       .homeInfo?.homeData.thisMonthEvent.length
    //                       .clamp(0, 5),
    //                   scrollDirection: Axis.horizontal,
    //                   physics: BouncingScrollPhysics(),
    //                   itemBuilder: (context, index) {
    //                     return InkWell(
    //                       onTap: () async {
    //                         await eventDetailsController
    //                             .getEventData(
    //                           eventId: homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .thisMonthEvent[index]
    //                               .eventId,
    //                         );
    //                         Get.toNamed(
    //                           Routes.eventDetailsScreen,
    //                           arguments: {
    //                             "eventId": homePageController
    //                                 .homeInfo
    //                                 ?.homeData
    //                                 .thisMonthEvent[index]
    //                                 .eventId,
    //                             "bookStatus": "1",
    //                           },
    //                         );
    //                       },
    //                       child: Container(
    //                         height: Get.height * 0.37,
    //                         width: Get.width / 1.5,
    //                         margin:
    //                         EdgeInsets.symmetric(horizontal: 8),
    //                         child: Column(
    //                           children: [
    //                             Container(
    //                               height: Get.height / 4.9,
    //                               width: Get.width / 1.4,
    //                               margin: EdgeInsets.all(5),
    //                               child: ClipRRect(
    //                                 borderRadius:
    //                                 BorderRadius.circular(20),
    //                                 child: FadeInImage.assetNetwork(
    //                                   placeholder:
    //                                   "assets/ezgif.com-crop.gif",
    //                                   height: Get.height / 4.9,
    //                                   width: Get.width / 1.4,
    //                                   image:
    //                                   "${Config.imageUrl}${homePageController.homeInfo?.homeData.thisMonthEvent[index].eventImg ?? ""}",
    //                                   fit: BoxFit.cover,
    //                                 ),
    //                               ),
    //                             ),
    //                             Container(
    //                               height: 65,
    //                               width: Get.size.width,
    //                               alignment: Alignment.center,
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: Column(
    //                                       mainAxisAlignment:
    //                                       MainAxisAlignment
    //                                           .center,
    //                                       crossAxisAlignment:
    //                                       CrossAxisAlignment
    //                                           .start,
    //                                       children: [
    //                                         Text(
    //                                           homePageController
    //                                               .homeInfo
    //                                               ?.homeData
    //                                               .thisMonthEvent[
    //                                           index]
    //                                               .eventTitle ??
    //                                               "",
    //                                           maxLines: 2,
    //                                           style: TextStyle(
    //                                             color: BlackColor,
    //                                             fontFamily:
    //                                             FontFamily
    //                                                 .gilroyBold,
    //                                             fontSize: 15,
    //                                             overflow:
    //                                             TextOverflow
    //                                                 .ellipsis,
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                           height: 4,
    //                                         ),
    //                                         Row(
    //                                           children: [
    //                                             Image.asset(
    //                                               "assets/Location.png",
    //                                               color: BlackColor,
    //                                               height: 15,
    //                                               width: 15,
    //                                             ),
    //                                             SizedBox(
    //                                               width: 4,
    //                                             ),
    //                                             SizedBox(
    //                                               width: Get.size
    //                                                   .width *
    //                                                   0.54,
    //                                               child: Text(
    //                                                 homePageController
    //                                                     .homeInfo
    //                                                     ?.homeData
    //                                                     .thisMonthEvent[
    //                                                 index]
    //                                                     .eventPlaceName ??
    //                                                     "",
    //                                                 maxLines: 1,
    //                                                 style:
    //                                                 TextStyle(
    //                                                   fontFamily:
    //                                                   FontFamily
    //                                                       .gilroyMedium,
    //                                                   fontSize: 15,
    //                                                   color:
    //                                                   BlackColor,
    //                                                   overflow:
    //                                                   TextOverflow
    //                                                       .ellipsis,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         )
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 10),
    //                               child: Divider(
    //                                 color: Colors.grey.shade300,
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               height: 6,
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.symmetric(
    //                                   horizontal: 15),
    //                               child: Row(
    //                                 children: [
    //                                   Text(
    //                                     homePageController
    //                                         .homeInfo
    //                                         ?.homeData
    //                                         .thisMonthEvent[
    //                                     index]
    //                                         .eventSdate ??
    //                                         "",
    //                                     style: TextStyle(
    //                                       fontFamily: FontFamily
    //                                           .gilroyMedium,
    //                                       color: greytext,
    //                                       fontSize: 14,
    //                                     ),
    //                                   )
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         ),
    //                         decoration: BoxDecoration(
    //                           color: WhiteColor,
    //                           borderRadius:
    //                           BorderRadius.circular(20),
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.upcomingEvent.isNotEmpty
    //                   ? Row(
    //                 children: [
    //                   SizedBox(
    //                     width: 15,
    //                   ),
    //                   Text(
    //                     "Upcoming Event".tr,
    //                     style: TextStyle(
    //                       fontFamily: FontFamily.gilroyBold,
    //                       color: BlackColor,
    //                       fontSize: 17,
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   TextButton(
    //                     onPressed: () {
    //                       Get.to(UpComingEvent());
    //                     },
    //                     child: Text(
    //                       "See All".tr,
    //                       style: TextStyle(
    //                         fontFamily: FontFamily.gilroyMedium,
    //                         color: gradient.defoultColor,
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                 ],
    //               )
    //                   : SizedBox(),
    //               homePageController.homeInfo!.homeData.upcomingEvent.isNotEmpty
    //                   ? ListView.builder(
    //                 itemCount: homePageController
    //                     .homeInfo?.homeData.upcomingEvent.length
    //                     .clamp(0, 5),
    //                 shrinkWrap: true,
    //                 physics: NeverScrollableScrollPhysics(),
    //                 padding: EdgeInsets.zero,
    //                 itemBuilder: (context, index) {
    //                   return InkWell(
    //                     onTap: () async {
    //                       await eventDetailsController.getEventData(
    //                         eventId: homePageController
    //                             .homeInfo
    //                             ?.homeData
    //                             .upcomingEvent[index]
    //                             .eventId,
    //                       );
    //                       Get.toNamed(
    //                         Routes.eventDetailsScreen,
    //                         arguments: {
    //                           "eventId": homePageController
    //                               .homeInfo
    //                               ?.homeData
    //                               .upcomingEvent[index]
    //                               .eventId,
    //                           "bookStatus": "1",
    //                         },
    //                       );
    //                     },
    //                     child: Container(
    //                       height: 120,
    //                       width: Get.size.width,
    //                       margin: EdgeInsets.only(
    //                           left: 10,
    //                           right: 10,
    //                           bottom: 10,
    //                           top: index == 0 ? 0 : 10),
    //                       child: Row(
    //                         children: [
    //                           Container(
    //                             height: 120,
    //                             width: 100,
    //                             margin: EdgeInsets.all(8),
    //                             alignment: Alignment.center,
    //                             child: ClipRRect(
    //                               borderRadius:
    //                               BorderRadius.circular(15),
    //                               child: FadeInImage.assetNetwork(
    //                                 placeholder:
    //                                 "assets/ezgif.com-crop.gif",
    //                                 height: 120,
    //                                 width: 100,
    //                                 placeholderCacheHeight: 120,
    //                                 placeholderCacheWidth: 100,
    //                                 image:
    //                                 "${Config.imageUrl}${homePageController.homeInfo?.homeData.upcomingEvent[index].eventImg}",
    //                                 fit: BoxFit.cover,
    //                               ),
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 5,
    //                           ),
    //                           Expanded(
    //                             child: Column(
    //                               crossAxisAlignment:
    //                               CrossAxisAlignment.start,
    //                               mainAxisAlignment:
    //                               MainAxisAlignment.center,
    //                               children: [
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventTitle ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyBold,
    //                                           fontSize: 15,
    //                                           color: BlackColor,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 SizedBox(
    //                                   height: 5,
    //                                 ),
    //                                 Row(
    //                                   children: [
    //                                     Expanded(
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventSdate ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           fontSize: 14,
    //                                           color: greytext,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 SizedBox(
    //                                   height: 3,
    //                                 ),
    //                                 Row(
    //                                   children: [
    //                                     Image.asset(
    //                                       "assets/Location.png",
    //                                       color: BlackColor,
    //                                       height: 15,
    //                                       width: 15,
    //                                     ),
    //                                     SizedBox(
    //                                       width: 4,
    //                                     ),
    //                                     SizedBox(
    //                                       width:
    //                                       Get.size.width * 0.55,
    //                                       child: Text(
    //                                         homePageController
    //                                             .homeInfo
    //                                             ?.homeData
    //                                             .upcomingEvent[
    //                                         index]
    //                                             .eventPlaceName ??
    //                                             "",
    //                                         maxLines: 1,
    //                                         style: TextStyle(
    //                                           fontFamily: FontFamily
    //                                               .gilroyMedium,
    //                                           fontSize: 15,
    //                                           color: BlackColor,
    //                                           overflow: TextOverflow
    //                                               .ellipsis,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 )
    //                               ],
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 10,
    //                           ),
    //                         ],
    //                       ),
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(15),
    //                         color: WhiteColor,
    //                       ),
    //                     ),
    //                   );
    //                 },
    //               )
    //                   : SizedBox(),
    //               SizedBox(
    //                 height: 20,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
