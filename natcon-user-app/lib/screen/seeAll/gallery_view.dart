// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../Api/config.dart';
import '../../controller/eventdetails_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
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
          "Gallary".tr,
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: GridView.builder(
            itemCount: eventDetailsController.eventInfo?.eventGallery.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 100,
            ),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/ezgif.com-crop.gif",
                      placeholderCacheHeight: 100,
                      placeholderCacheWidth: 100,
                      placeholderFit: BoxFit.cover,
                      height: 100,
                      width: 100,
                      image: Config.imageUrl + eventDetailsController.eventInfo!.eventGallery[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PhotoViewPage extends StatefulWidget {
  final List<String> photos;
  final int index;

  const PhotoViewPage({
    super.key,
    required this.photos,
    required this.index,
  });

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  EventDetailsController eventDetailsController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        itemCount: eventDetailsController.eventInfo!.eventGallery.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          child: CachedNetworkImage(
            height: Get.height,
            width: Get.width,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
            imageUrl: "${Config.imageUrl}${widget.photos[index]}",
            placeholder: (context, url) => Container(
              height: Get.height,
              width: Get.width,
              child: Image.asset(
                "assets/ezgif.com-crop.gif",
                fit: BoxFit.cover,
              ),
              decoration: BoxDecoration(
                color: WhiteColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.white,
              child: Center(child: Text(error.toString(),style: TextStyle(color: Colors.black),)),
            ),
          ),
          minScale: PhotoViewComputedScale.covered,
          heroAttributes: PhotoViewHeroAttributes(tag: "${Config.imageUrl}${widget.photos[index]}"),
        ),
        pageController: PageController(initialPage: widget.index),
        enableRotation: false,
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  String? imageUrl;
  String? tag;
  FullScreenImage({this.imageUrl, this.tag});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag ?? "",
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              imageUrl: imageUrl ?? "",
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
