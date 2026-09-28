// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/eventdetails_controller.dart';
import '../../controller/favorites_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoriteController favoriteController = Get.find();
  EventDetailsController eventDetailsController = Get.find();

  @override
  void initState() {
    favoriteController.getFavoriteListApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        centerTitle: true,
        elevation: 0,
        leading: SizedBox(),
        title: Text(
          "Favorites".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
            color: BlackColor,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: GetBuilder<FavoriteController>(builder: (context) {
          return favoriteController.isLoading
              ? favoriteController.favList.isNotEmpty
                  ? ListView.builder(
                      itemCount: favoriteController.favList.length,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await eventDetailsController.getEventData(
                              eventId:
                                  favoriteController.favList[index].eventId,
                            );
                            Get.toNamed(
                              Routes.eventDetailsScreen,
                              arguments: {
                                "eventId":
                                    favoriteController.favList[index].eventId,
                                "bookStatus": "1",
                              },
                            );
                          },
                          child: Container(
                            height: 140,
                            width: Get.size.width,
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 140,
                                      width: 130,
                                      margin: EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage.assetNetwork(
                                          fadeInCurve: Curves.easeInCirc,
                                          placeholder:
                                              "assets/ezgif.com-crop.gif",
                                          height: 140,
                                          image:
                                              "${Config.imageUrl}${favoriteController.favList[index].eventImg}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    Positioned(
                                      left: 15,
                                      top: 15,
                                      child: InkWell(
                                        onTap: () {
                                          bottomSheet(index);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          padding: EdgeInsets.all(9),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            "assets/Fev-Bold.png",
                                            color: gradient.defoultColor,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF000000)
                                                .withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        favoriteController
                                            .favList[index].eventTitle,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 15,
                                          color: BlackColor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        favoriteController
                                            .favList[index].eventSdate,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          color: gradient.defoultColor,
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
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
                                            width: Get.size.width * 0.49,
                                            child: Text(
                                              favoriteController.favList[index]
                                                  .eventPlaceName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
                                                fontSize: 14,
                                                color: BlackColor,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: WhiteColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "Sorry, Favorite List Empty".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 15,
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

  Future bottomSheet(int index) {
    return Get.bottomSheet(
      Container(
        height: 350,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Remove from Favorites?".tr,
              style: TextStyle(
                fontSize: 20,
                fontFamily: FontFamily.gilroyBold,
                color: BlackColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Divider(
                color: greytext,
              ),
            ),
            Container(
              height: 140,
              width: Get.size.width,
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    height: 140,
                    width: 130,
                    margin: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FadeInImage.assetNetwork(
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: "assets/ezgif.com-crop.gif",
                        height: 140,
                        image:
                            "${Config.imageUrl}${favoriteController.favList[index].eventImg}",
                        fit: BoxFit.cover,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          favoriteController.favList[index].eventTitle,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 15,
                            color: BlackColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          favoriteController.favList[index].eventSdate,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: gradient.defoultColor,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 8,
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
                              width: 4,
                            ),
                            SizedBox(
                              width: Get.size.width * 0.5,
                              child: Text(
                                favoriteController
                                    .favList[index].eventPlaceName,
                                maxLines: 2,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 14,
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
                ],
              ),
              decoration: BoxDecoration(
                color: WhiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
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
                        "Cancle".tr,
                        style: TextStyle(
                          color: gradient.defoultColor,
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFeef4ff),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      eventDetailsController.getFavAndUnFav(eventID: favoriteController.favList[index].eventId);
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes, Remove".tr,
                        style: TextStyle(
                          color: WhiteColor,
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: gradient.defoultColor,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        decoration: BoxDecoration(
          color: WhiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
    );
  }
}
