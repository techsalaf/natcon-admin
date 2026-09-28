// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/eventdetails_controller.dart';
import '../../controller/home_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class UpComingEvent extends StatefulWidget {
  const UpComingEvent({super.key});

  @override
  State<UpComingEvent> createState() => _UpComingEventState();
}

class _UpComingEventState extends State<UpComingEvent> {
  HomePageController homePageController = Get.find();
  EventDetailsController eventDetailsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: BlackColor,
          ),
        ),
        title: Text(
          "Upcoming Event".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
          ),
        ),
      ),
      body: GetBuilder<HomePageController>(builder: (context) {
        return Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: homePageController.homeInfo!.homeData.upcomingEvent.isNotEmpty
                  ? ListView.builder(
                itemCount:
                    homePageController.homeInfo?.homeData.upcomingEvent.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await eventDetailsController.getEventData(
                        eventId: homePageController
                            .homeInfo?.homeData.upcomingEvent[index].eventId,
                      );
                      Get.toNamed(
                        Routes.eventDetailsScreen,
                        arguments: {
                          "eventId": homePageController
                              .homeInfo?.homeData.upcomingEvent[index].eventId,
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
                        top: index == 0 ? 0 : 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 120,
                            width: 100,
                            margin: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: FadeInImage.assetNetwork(
                                placeholder: "assets/ezgif.com-crop.gif",
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        homePageController
                                                .homeInfo
                                                ?.homeData
                                                .upcomingEvent[index]
                                                .eventTitle ??
                                            "",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 15,
                                          color: BlackColor,
                                          overflow: TextOverflow.ellipsis,
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
                                                .upcomingEvent[index]
                                                .eventSdate ??
                                            "",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 13,
                                          color: greytext,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/Location.png",
                                      color: gradient.defoultColor,
                                      height: 15,
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: Get.size.width * 0.55,
                                      child: Text(
                                        homePageController
                                                .homeInfo
                                                ?.homeData
                                                .upcomingEvent[index]
                                                .eventPlaceName ??
                                            "",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 15,
                                          color: BlackColor,
                                          overflow: TextOverflow.ellipsis,
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
            ),
          ],
        );
      }),
    );
  }
}
