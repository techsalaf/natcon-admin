// ignore_for_file: prefer_const_constructors, unused_field, unused_local_variable, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../utils/Colors.dart';

class VideoPreviewScreen extends StatefulWidget {
  String? url;
  VideoPreviewScreen({super.key, this.url});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    String? videoIdd = YoutubePlayer.convertUrlToId(widget.url ?? "");
    _controller = YoutubePlayerController(
      initialVideoId: videoIdd ?? "",
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          aspectRatio: 8 / 13,
          bufferIndicator: CircularProgressIndicator(
            color: Colors.red,
          ),
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
        builder: (p0, p1) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: WhiteColor,
              elevation: 0,
              leading: BackButton(
                onPressed: () {
                  Get.back();
                },
                color: BlackColor,
              ),
            ),
            body: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.center,
              child: p1,
            ),
          );
        },
      ),
    );
  }
}
