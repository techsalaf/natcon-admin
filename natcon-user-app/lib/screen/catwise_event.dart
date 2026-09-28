// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api/config.dart';
import '../controller/eventdetails_controller.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';

class CatWiseEvent extends StatefulWidget {
  const CatWiseEvent({super.key});

  @override
  State<CatWiseEvent> createState() => _CatWiseEventState();
}

class _CatWiseEventState extends State<CatWiseEvent> {
  EventDetailsController eventDetailsController = Get.find();
  String title = Get.arguments["title"];
  String img = Get.arguments["catImag"];
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = Get.height * 0.18;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: WhiteColor,
              expandedHeight: 180,
              leading: BackButton(
                color: _isShrink ? BlackColor : WhiteColor,
                onPressed: () {
                  Get.back();
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: _isShrink ? BlackColor : WhiteColor,
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  height: 180,
                  width: Get.size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    child: Image.network(
                      Config.imageUrl + img,
                      fit: BoxFit.cover,
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: GetBuilder<EventDetailsController>(builder: (context) {
          return eventDetailsController.isLoading
              ? eventDetailsController.catWiseInfo.isNotEmpty
                  ? ListView.builder(
                      itemCount: eventDetailsController.catWiseInfo.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await eventDetailsController.getEventData(
                              eventId: eventDetailsController
                                  .catWiseInfo[index].eventId,
                            );
                            Get.toNamed(
                              Routes.eventDetailsScreen,
                              arguments: {
                                "eventId": eventDetailsController
                                    .catWiseInfo[index].eventId,
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
                                          "${Config.imageUrl}${eventDetailsController.catWiseInfo[index].eventImg}",
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
                                              eventDetailsController
                                                  .catWiseInfo[index]
                                                  .eventTitle,
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
                                        height: 7,
                                      ),
                                      Text(
                                        eventDetailsController
                                            .catWiseInfo[index].eventPlaceName,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 14,
                                          color: greytext,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              eventDetailsController
                                                  .catWiseInfo[index]
                                                  .eventSdate,
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
        }),
      ),
    );
  }
}
