// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api/config.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/search_controller.dart' as sear;
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';

class SearchEventScreen extends StatefulWidget {
  const SearchEventScreen({super.key});

  @override
  State<SearchEventScreen> createState() => _SearchEventScreenState();
}

class _SearchEventScreenState extends State<SearchEventScreen> {
  TextEditingController search = TextEditingController();
  sear.SearchController searchController = Get.find();
  EventDetailsController eventDetailsController = Get.find();

  @override
  void initState() {
    super.initState();
    search.text = "";
    searchController.getSearchForEvent(keyWord: "a");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: GetBuilder<sear.SearchController>(builder: (context) {
        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      width: Get.size.width,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, right: 8),
                        child: TextField(
                          controller: search,
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {},
                          onChanged: (value) {
                            value != ""
                                ? searchController.getSearchForEvent(
                                    keyWord: value)
                                : searchController.getSearchForEvent(
                                    keyWord: "a");
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 6),
                            border: InputBorder.none,
                            hintText: "Search for Event".tr,
                            hintStyle: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: greytext,
                            ),
                            prefixIcon: InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: BlackColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: WhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              searchController.isLoading
                  ? searchController.searchInfo.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: searchController.searchInfo.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  await eventDetailsController.getEventData(
                                    eventId: searchController
                                        .searchInfo[index].eventId,
                                  );
                                  Get.toNamed(
                                    Routes.eventDetailsScreen,
                                    arguments: {
                                      "eventId": searchController
                                          .searchInfo[index].eventId,
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/ezgif.com-crop.gif",
                                            height: 120,
                                            width: 100,
                                            placeholderCacheHeight: 120,
                                            placeholderCacheWidth: 100,
                                            image:
                                                "${Config.imageUrl}${searchController.searchInfo[index].eventImg}",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    searchController
                                                        .searchInfo[index]
                                                        .eventTitle,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FontFamily.gilroyBold,
                                                      fontSize: 15,
                                                      color: BlackColor,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Text(
                                              searchController.searchInfo[index]
                                                  .eventPlaceName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
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
                                                    searchController
                                                        .searchInfo[index]
                                                        .eventSdate,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      fontSize: 14,
                                                      color: greytext,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: Text(
                              "No Data Found!".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 15,
                                color: BlackColor,
                              ),
                            ),
                          ),
                        )
                  : Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: gradient.defoultColor,
                        ),
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }
}
