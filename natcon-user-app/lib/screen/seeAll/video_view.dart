// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../controller/eventdetails_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../videopreview_screen.dart';

class VideoViewScreen extends StatefulWidget {
  const VideoViewScreen({super.key});

  @override
  State<VideoViewScreen> createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
  EventDetailsController eventDetailsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Get.back();
          },
          color: BlackColor,
        ),
        title: Text(
          "Video".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
            fontSize: 16,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: GridView.builder(
            itemCount: eventDetailsController
                .eventInfo?.eventData.eventVideoUrls.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 5,
              mainAxisExtent: 100,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.to(VideoPreviewScreen(
                    url: eventDetailsController
                            .eventInfo?.eventData.eventVideoUrls[index] ??
                        "",
                  ));
                },
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/ezgif.com-crop.gif",
                          placeholderCacheHeight: 100,
                          placeholderCacheWidth: 100,
                          placeholderFit: BoxFit.cover,
                          image: YoutubePlayer.getThumbnail(
                            videoId: YoutubePlayer.convertUrlToId(
                                eventDetailsController.eventInfo?.eventData
                                        .eventVideoUrls[index] ??
                                    "")!,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
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
                            offset: const Offset(0.0, 0.0),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
