// ignore_for_file: prefer_const_constructors, file_names, sort_child_properties_last, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/eventdetails_controller.dart';
import '../../controller/org_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../myTicket/myticket_screen.dart';

class OrganizerInformation extends StatefulWidget {
  String? orgImg;
  String? orgId;
  String? orgName;
  OrganizerInformation({super.key, this.orgImg, this.orgId, this.orgName});

  @override
  State<OrganizerInformation> createState() => _OrganizerInformationState();
}

class _OrganizerInformationState extends State<OrganizerInformation>
    with TickerProviderStateMixin {
  OrgController orgController = Get.put(OrgController());
  EventDetailsController eventDetailsController = Get.find();

  TabController? _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _tabController?.index == 0;
    if (_tabController?.index == 0) {
      orgController.getStatusWiseEvent(
        orgId: widget.orgId,
        status: "Today",
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: Container(
        color: transparent,
        height: Get.height,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: CustomShape(),
                  child: Container(
                    height: Get.height * 0.29,
                    width: Get.size.width,
                    child: Column(
                      children: [
                        SizedBox(height: Get.height * 0.047),
                        Row(
                          children: [
                            BackButton(
                              color: WhiteColor,
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Organizer Information".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 15,
                                color: WhiteColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient.btnGradient,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -25,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        padding: EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/ezgif.com-crop.gif",
                            image: "${Config.imageUrl}${widget.orgImg}",
                            placeholderFit: BoxFit.cover,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: WhiteColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        left: 68,
                        bottom: 4,
                        child: Container(
                          height: 30,
                          width: 30,
                          padding: EdgeInsets.all(3),
                          child: Image.asset(
                            "assets/badge-check.png",
                            color: gradient.defoultColor,
                            height: 20,
                            width: 20,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: WhiteColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Get.size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.orgName ?? "",
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 15,
                    color: BlackColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            SizedBox(
              height: 40,
              child: TabBar(
                indicatorColor: gradient.defoultColor,
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                unselectedLabelColor: greyColor,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 16,
                  color: gradient.defoultColor,
                ),
                indicator: MD2Indicator(
                  indicatorSize: MD2IndicatorSize.full,
                  indicatorHeight: 3,
                  indicatorColor: gradient.defoultColor,
                ),
                labelColor: gradient.defoultColor,
                onTap: (value) {
                  if (value == 0) {
                    orgController.getStatusWiseEvent(
                      orgId: widget.orgId,
                      status: "Today",
                    );
                  } else if (value == 1) {
                    orgController.getStatusWiseEvent(
                      orgId: widget.orgId,
                      status: "Upcoming",
                    );
                  } else {
                    orgController.getStatusWiseEvent(
                      orgId: widget.orgId,
                      status: "Past",
                    );
                  }
                },
                tabs: [
                  Tab(
                    text: "Today's Event".tr,
                  ),
                  Tab(
                    text: "Upcoming".tr,
                  ),
                  Tab(
                    text: "Past".tr,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  todayEventWidget(),
                  upcomingEventWidget(),
                  pastEventWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  todayEventWidget() {
    return GetBuilder<OrgController>(builder: (context) {
      return orgController.isLoading
          ? orgController.orgInfo!.orderData.isNotEmpty
              ? SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: orgController.orgInfo?.orderData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await eventDetailsController.getEventData(
                            eventId:
                                orgController.orgInfo?.orderData[index].eventId,
                          );
                          Get.toNamed(
                            Routes.eventDetailsScreen,
                            arguments: {
                              "eventId": orgController
                                  .orgInfo?.orderData[index].eventId,
                              "bookStatus": "1",
                            },
                          );
                        },
                        child: Container(
                          height: 120,
                          width: Get.size.width,
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
                                        "${Config.imageUrl}${orgController.orgInfo?.orderData[index].eventImg}",
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                          width: 210,
                                          child: Text(
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                )
              : Center(
                  child: Text(
                    'Event Not Available!'.tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 17,
                      color: BlackColor,
                    ),
                  ),
                )
          : Center(
              child: CircularProgressIndicator(
                color: gradient.defoultColor,
              ),
            );
    });
  }

  upcomingEventWidget() {
    return GetBuilder<OrgController>(builder: (context) {
      return orgController.isLoading
          ? orgController.orgInfo!.orderData.isNotEmpty
              ? SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: orgController.orgInfo?.orderData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await eventDetailsController.getEventData(
                            eventId:
                                orgController.orgInfo?.orderData[index].eventId,
                          );
                          Get.toNamed(
                            Routes.eventDetailsScreen,
                            arguments: {
                              "eventId": orgController
                                  .orgInfo?.orderData[index].eventId,
                              "bookStatus": "1",
                            },
                          );
                        },
                        child: Container(
                          height: 120,
                          width: Get.size.width,
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
                                        "${Config.imageUrl}${orgController.orgInfo?.orderData[index].eventImg}",
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                          width: 210,
                                          child: Text(
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                )
              : Center(
                  child: Text(
                    'Event Not Available!'.tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 17,
                      color: BlackColor,
                    ),
                  ),
                )
          : Center(
              child: CircularProgressIndicator(
                color: gradient.defoultColor,
              ),
            );
    });
  }

  pastEventWidget() {
    return GetBuilder<OrgController>(builder: (context) {
      return orgController.isLoading
          ? orgController.orgInfo!.orderData.isNotEmpty
              ? SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: orgController.orgInfo?.orderData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await eventDetailsController.getEventData(
                            eventId:
                                orgController.orgInfo?.orderData[index].eventId,
                          );
                          Get.toNamed(
                            Routes.eventDetailsScreen,
                            arguments: {
                              "eventId": orgController
                                  .orgInfo?.orderData[index].eventId,
                              "bookStatus": "2",
                            },
                          );
                        },
                        child: Container(
                          height: 120,
                          width: Get.size.width,
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
                                        "${Config.imageUrl}${orgController.orgInfo?.orderData[index].eventImg}",
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                                          width: 210,
                                          child: Text(
                                            orgController
                                                    .orgInfo
                                                    ?.orderData[index]
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
                )
              : Center(
                  child: Text(
                    'Event Not Available!'.tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 17,
                      color: BlackColor,
                    ),
                  ),
                )
          : Center(
              child: CircularProgressIndicator(
                color: gradient.defoultColor,
              ),
            );
    });
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
