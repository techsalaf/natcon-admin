// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_unnecessary_containers, sized_box_for_whitespace, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, prefer_collection_literals

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:magicmate_user/screen/searchevent_screen.dart';

import '../Api/config.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/home_controller.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  HomePageController homePageController = Get.find();
  EventDetailsController eventDetailsController = Get.find();
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // var maplist = homePageController.mapInfo.reversed.toList();
    // for (var i = 0; i < maplist.length; i++) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhiteColor,
      body: GetBuilder<HomePageController>(builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Container(
                height: Get.size.height,
                child: GoogleMap(
                  initialCameraPosition: homePageController.kGoogle,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  markers: Set<Marker>.of(homePageController.markers),
                  mapType: MapType.normal,
                  myLocationEnabled: false,
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
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.to(SearchEventScreen());
                            },
                            child: Container(
                              height: 45,
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
                                      fontFamily: FontFamily.gilroyMedium,
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
                        ),
                        InkWell(
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
                              Icons.close,
                              color: WhiteColor,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF000000).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    height: 120,
                    width: Get.size.width,
                    child: PageView.builder(
                      controller: homePageController.pageController,
                      itemCount: homePageController
                          .homeInfo?.homeData.nearbyEvent.length,
                      onPageChanged: (int index) {
                        mapController
                            .animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                double.parse(homePageController
                                        .homeInfo
                                        ?.homeData
                                        .nearbyEvent[index]
                                        .eventLatitude ??
                                    "0"),
                                double.parse(homePageController
                                        .homeInfo
                                        ?.homeData
                                        .nearbyEvent[index]
                                        .eventLongtitude ??
                                    ""),
                              ),
                              zoom: 12,
                            ),
                          ),
                        )
                            .then((val) {
                          setState(() {});
                        });
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await eventDetailsController.getEventData(
                              eventId: homePageController.homeInfo?.homeData
                                  .nearbyEvent[index].eventId,
                            );
                            Get.toNamed(
                              Routes.eventDetailsScreen,
                              arguments: {
                                "eventId": homePageController.homeInfo?.homeData
                                    .nearbyEvent[index].eventId,
                                "bookStatus": "1",
                              },
                            );
                          },
                          child: Container(
                            height: 120,
                            width: Get.size.width * 0.9,
                            margin: EdgeInsets.all(10),
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
                                          "${Config.imageUrl}${homePageController.homeInfo?.homeData.nearbyEvent[index].eventImg}",
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              homePageController
                                                      .homeInfo
                                                      ?.homeData
                                                      .nearbyEvent[index]
                                                      .eventTitle ??
                                                  "",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyBold,
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
                                                      .nearbyEvent[index]
                                                      .eventSdate ??
                                                  "",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
                                                fontSize: 14,
                                                color: greytext,
                                                overflow: TextOverflow.ellipsis,
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
                                            width: Get.size.width * 0.54,
                                            child: Text(
                                              homePageController
                                                      .homeInfo
                                                      ?.homeData
                                                      .nearbyEvent[index]
                                                      .eventPlaceName ??
                                                  "",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
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
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
