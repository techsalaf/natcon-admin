// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names

import 'package:magicmate_organizer/Dashboard/Artist%20List/Addartistlist_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Addartist_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Artist_controller.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Getx_controller.dart/Dashboard_controller.dart';

class Artistlistscreen extends StatefulWidget {
  const Artistlistscreen({super.key});

  @override
  State<Artistlistscreen> createState() => _ArtistlistscreenState();
}

class _ArtistlistscreenState extends State<Artistlistscreen> {
  ArtistController artistController = Get.find();
  AddartistController addartistController = Get.find();
  DashboardController dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    artistController.artistlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifier.containerColor,
      appBar: CustomAppbar(
        context: context,
          onTap: () {
            Get.to(() => Addartistlistscreen(
                  add: "Add",
                ));
          },
          title: "Artist List".tr),
      body: GetBuilder<ArtistController>(builder: (context) {
        return !artistController.isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : artistController.artistinfo == null ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                "No Artist placed!",
                style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15),
              ),
              SizedBox(height: 5),
              Text(
                "Currently you don’t have any Artist.",
                style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: greycolor),
              ),
            ],
          ),
        ) : artistController.artistinfo!.artistdata.isNotEmpty
                ? SingleChildScrollView(
          physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        SizedBox(height: Get.height * 0.02),
                        ListView.builder(
                            itemCount:
                                artistController.artistinfo?.artistdata.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {},
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 125,
                                      width: Get.size.width,
                                      margin: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                height: 125,
                                                width: 110,
                                                margin: EdgeInsets.all(10),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Image.network(

                                                    "${AppUrl.imageurl}${artistController.artistinfo?.artistdata[index].image ?? ""}",
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
                                            width: 4,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 25),
                                                        child: Text(
                                                          // "Artist Name",
                                                          artistController
                                                                  .artistinfo
                                                                  ?.artistdata[
                                                                      index]
                                                                  .eventTitle ??
                                                              "",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                            color: notifier.textColor,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height: Get.height * 0.005),
                                                Row(
                                                  children: [
                                                    // extraimageController.extraimages
                                                    //             ?.extralist[index].status ==
                                                    //         "0"
                                                    //     ?
                                                    Text(
                                                      artistController
                                                              .artistinfo
                                                              ?.artistdata[
                                                                  index]
                                                              .title ??
                                                          "",
                                                      style: TextStyle(
                                                        color: greycolor,
                                                        fontFamily: FontFamily
                                                            .gilroyMedium,
                                                      ),
                                                    ),

                                                    // : Text(
                                                    //     "Publish",
                                                    //     style: TextStyle(
                                                    //       color: greyColor,
                                                    //       fontFamily:
                                                    //           FontFamily.gilroyMedium,
                                                    //     ),
                                                    //   ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  artistController
                                                          .artistinfo
                                                          ?.artistdata[index]
                                                          .arole ??
                                                      "",
                                                  style: TextStyle(
                                                    color: greycolor,
                                                    fontFamily:
                                                        FontFamily.gilroyMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: notifier.border),
                                        color: notifier.background,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                          onTap: () {
                                            addartistController.getEditDetails(
                                              artistImage1: artistController
                                                      .artistinfo
                                                      ?.artistdata[index]
                                                      .image ??
                                                  "",
                                              artistName1: artistController
                                                      .artistinfo
                                                      ?.artistdata[index]
                                                      .title ??
                                                  "",
                                              artistRole1: artistController
                                                      .artistinfo
                                                      ?.artistdata[index]
                                                      .arole ??
                                                  "",
                                            );
                                            Get.to(
                                              () => Addartistlistscreen(
                                                add: "edit",
                                                eventName: artistController
                                                        .artistinfo
                                                        ?.artistdata[index]
                                                        .eventTitle ??
                                                    "",
                                                eventId: artistController
                                                        .artistinfo
                                                        ?.artistdata[index]
                                                        .eventId ??
                                                    "",
                                                recodeId: artistController
                                                        .artistinfo
                                                        ?.artistdata[index]
                                                        .id ??
                                                    "",
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            padding: EdgeInsets.all(9),
                                            alignment: Alignment.center,
                                            child:
                                                Image.asset("assets/Pen.png"),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: gradient.btnGradient,
                                            ),
                                          )),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                )
                : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                "No Artist placed!",
                style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 15),
              ),
              SizedBox(height: 5),
              Text(
                "Currently you don’t have any Artist.",
                style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: greycolor),
              ),
            ],
          ),
        );
      }),
    );
  }
}
