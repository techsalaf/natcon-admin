// ignore_for_file: prefer_const_constructors, sort_child_properties_last, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Api/config.dart';
import '../../controller/org_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  OrgController orgController = Get.find();
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
          "Attendees".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
            fontSize: 17,
          ),
        ),
      ),
      body: GetBuilder<OrgController>(builder: (context) {
        return SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: orgController.isLoading
              ? orgController.userInfo!.joinedUserdata.isNotEmpty
                  ? ListView.builder(
                      itemCount: orgController.userInfo?.joinedUserdata.length,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/ezgif.com-crop.gif",
                                  height: 50,
                                  width: 50,
                                  image:
                                      "${Config.imageUrl}${orgController.userInfo?.joinedUserdata[index].userImg ?? ""}",
                                  placeholderFit: BoxFit.cover,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              orgController.userInfo?.joinedUserdata[index]
                                      .customername ??
                                  "",
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: BlackColor,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  "${orgController.userInfo?.joinedUserdata[index].totalTicketPurchase ?? ""}x",
                                  style: TextStyle(
                                    color: greytext,
                                    fontFamily: FontFamily.gilroyMedium,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  orgController.userInfo?.joinedUserdata[index]
                                          .totalType ??
                                      "",
                                  style: TextStyle(
                                    color: greytext,
                                    fontFamily: FontFamily.gilroyMedium,
                                  ),
                                )
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: WhiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'User Not Available!'.tr,
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
                ),
        );
      }),
    );
  }
}
