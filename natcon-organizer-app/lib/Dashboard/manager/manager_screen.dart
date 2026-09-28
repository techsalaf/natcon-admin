import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Getx_controller.dart/add_manager_controller.dart';
import '../../Getx_controller.dart/manager_list_controller.dart';
import '../../api_screens/data_store.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../../utils/Fontfamily.dart';
import '../../utils/dark_light_mode.dart';
import 'add_edit_manager.dart';

class ManagerScreen extends StatefulWidget {
  final String type;
  const                                                                                                                                                                                                                                           ManagerScreen({super.key, required this.type});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {

  ManagerListController managerListController = Get.put(ManagerListController());
  AddManagerController addManagerController = Get.put(AddManagerController());

  @override
  void initState() {
    managerListController.isLoading = false;
    print("+++++++++++++++++ ${widget.type.toUpperCase()}");
    getDarkMode();
    managerListController.managerListApi(context: context,orgID: getData.read("UserLogin")["id"],accountType: widget.type.toUpperCase());
    super.initState();
  }

  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.containerColor,
      appBar: CustomAppbar(
          context: context,
          onTap: () {
            addManagerController.buttonUpdate = true;
            if(addManagerController.buttonUpdate = true){
              addManagerController.nameController.clear();
              addManagerController.emailController.clear();
              addManagerController.passwordController.clear();
              addManagerController.managerType = "";
              addManagerController.accountType = "";
            }
            Get.to(() => AddEditManager(AccountType: widget.type,));
          },
          title: "${widget.type}"),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: GetBuilder<ManagerListController>(builder: (managerListController) {
            return managerListController.isLoading
                ? managerListController.managerListModel!.managerdata.isNotEmpty
                ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: managerListController.managerListModel!.managerdata.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            width: Get.size.width,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                orderInfo(
                                  title: "Name".tr,
                                  subtitle: managerListController.managerListModel!.managerdata[index].name,
                                ),
                                orderInfo(
                                  title: "E-mail".tr,
                                  subtitle: managerListController.managerListModel!.managerdata[index].email,
                                ),
                                orderInfo(
                                  title: "Password".tr,
                                  subtitle: managerListController.managerListModel!.managerdata[index].password,
                                ),
                                orderInfo(
                                  title: "Account Type".tr,
                                  subtitle: managerListController.managerListModel!.managerdata[index].managerType,
                                ),
                                orderInfo1(
                                  title: "Status".tr,
                                  subtitle: managerListController.managerListModel!.managerdata[index].status == "1" ? "Active" : "Deactivate",
                                  color: managerListController.managerListModel!.managerdata[index].status == "1" ? Colors.green : Colors.red,
                                ),
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
                            child: GestureDetector(
                              onTap: () {
                                addManagerController.buttonUpdate = false;
                                addManagerController.getIdAndName(
                                  managerId: managerListController.managerListModel!.managerdata[index].id.toString(),
                                  name: managerListController.managerListModel!.managerdata[index].name,
                                  email: managerListController.managerListModel!.managerdata[index].email,
                                  password: managerListController.managerListModel!.managerdata[index].password,
                                  manager: managerListController.managerListModel!.managerdata[index].managerType,
                                  status: managerListController.managerListModel!.managerdata[index].status,
                                );
                                Get.to(() => AddEditManager(AccountType: widget.type, managerId: managerListController.managerListModel!.managerdata[index].id.toString()));
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                padding: EdgeInsets.all(9),
                                alignment: Alignment.center,
                                child: Image.asset("assets/Pen.png"),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradient.btnGradient,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                                          },
                                        ),
                      SizedBox(height: Get.height * 0.03)
                    ],
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
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "No ${widget.type} placed!".tr,
                    style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        color: notifier.textColor,
                        fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Currently you don’t have any ${widget.type}.".tr,
                    style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: greycolor),
                  ),
                ],
              ),
            )
                : Center(child: CircularProgressIndicator(color: appcolor,));
          }),
          decoration: BoxDecoration(
            color: notifier.containerColor,
          ),
        ),
      ),
    );
  }
  orderInfo({String? title, subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title ?? "",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 13,
            color: greycolor,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          ":",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 13,
            color: greycolor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          subtitle ?? "",
          style:  TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifier.textColor,
          ),
        ),
      ],
    );
  }

  orderInfo1({String? title, subtitle, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title ?? "",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 13,
            color: greycolor,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Text(
          ":",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 13,
            color: greycolor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          subtitle ?? "",
          style:  TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: color,
          ),
        )
      ],
    );
  }

}
