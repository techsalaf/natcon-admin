import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../Getx_controller.dart/Dashboard_controller.dart';
import '../../Getx_controller.dart/add_manager_controller.dart';
import '../../Getx_controller.dart/manager_list_controller.dart';
import '../../api_screens/data_store.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../../utils/Fontfamily.dart';
import '../../utils/dark_light_mode.dart';


class AddEditManager extends StatefulWidget {
  String? managerId;
  final String AccountType;
   AddEditManager({this.managerId,super.key, required this.AccountType});

  @override
  State<AddEditManager> createState() => _AddEditManagerState();
}
List<String> status = ["SCANNER","MANAGER"];
List<String> accountStatus = ["active","deactive"];

class _AddEditManagerState extends State<AddEditManager> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    print("------------------ ${widget.AccountType.toUpperCase()}");
   getDarkMode();
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

  AddManagerController addManagerController = Get.put(AddManagerController());
  ManagerListController managerListController = Get.put(ManagerListController());
  DashboardController dashboardController = Get.put(DashboardController());

  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String slectStatus = status.first;
  String accountSelect = accountStatus.first;


  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: appbar(title: addManagerController.buttonUpdate == true ? "Add ${widget.AccountType}" : "Edit ${widget.AccountType}"),
      backgroundColor: notifier.containerColor,
      bottomNavigationBar: GetBuilder<AddManagerController>(
        builder: (addManagerController) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: GestButton(
                Width: Get.size.width,
                height: 55,
                gradient: gradient.btnGradient,
                buttontext: addManagerController.buttonUpdate == true ? "Add".tr : "Update".tr,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  color: WhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                onclick: addManagerController.buttonUpdate == true ? () {
                  if(addManagerController.nameController.text.isNotEmpty && addManagerController.emailController.text.isNotEmpty && addManagerController.passwordController.text.isNotEmpty && addManagerController.managerType != "" && addManagerController.accountType != ""){
                    addManagerController.addManagerApi(context: context,orgID: getData.read("UserLogin")["id"], name: addManagerController.nameController.text, email: addManagerController.emailController.text, password: addManagerController.passwordController.text, managerType: addManagerController.managerType, status: addManagerController.accountType).then((value) {
                      managerListController.managerListApi(context: context,orgID: getData.read("UserLogin")["id"],accountType: widget.AccountType.toUpperCase());
                      dashboardController.dashboard();
                      Get.back();
                      addManagerController.nameController.clear();
                      addManagerController.emailController.clear();
                      addManagerController.passwordController.clear();
                      addManagerController.managerType = "";
                      addManagerController.accountType = "";
                      setState(() {

                      });
                    },);
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Please Enter all the Field".tr),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    );
                  }
                }
                : (){
                  if(addManagerController.nameController.text.isNotEmpty && addManagerController.emailController.text.isNotEmpty && addManagerController.passwordController.text.isNotEmpty && addManagerController.managerType != "" && addManagerController.accountType != ""){

                    addManagerController.editManagerApi(context: context, recordId: widget.managerId.toString(),orgID: getData.read("UserLogin")["id"], name: addManagerController.nameController.text, email: addManagerController.emailController.text, password: addManagerController.passwordController.text, managerType: addManagerController.managerType, status: addManagerController.accountType).then((value) {
                      managerListController.managerListApi(context: context,orgID: getData.read("UserLogin")["id"],accountType: widget.AccountType.toUpperCase());
                      dashboardController.dashboard();
                      Get.back();
                      addManagerController.nameController.clear();
                      addManagerController.emailController.clear();
                      addManagerController.passwordController.clear();
                      addManagerController.managerType = "";
                      addManagerController.accountType = "";
                      setState(() {

                      });
                    },);
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Please Enter all the Field".tr),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    );
                  }
                }
                ),
          );
        }
      ),
      body: GetBuilder<AddManagerController>(
        builder: (addManagerController) {
          return Stack(
            children: [
              SizedBox(
                height: Get.size.height,
                width: Get.size.width,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.02),
                          textfield(
                            type: "Enter Name".tr,
                            controller: addManagerController.nameController,
                            labelText: "Enter Name".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Name'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Get.height * 0.02),
                          textfield(
                            type: "Enter E-mail".tr,
                            controller: addManagerController.emailController,
                            labelText: "Enter E-mail".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter E-mail'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Enter Password".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          passwordtextfield(
                            fill: true,
                            fillColor: notifier.background,
                            context: context,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            hint: "Enter Password",
                            controller: addManagerController.passwordController,
                            obscureText: _obscureText,
                            suffixIcon: InkWell(
                                onTap: () {
                                  _toggle();
                                },
                                child: !_obscureText
                                    ? Icon(
                                  Icons.visibility,
                                  color: orangeColor,
                                )
                                    : Icon(
                                  Icons.visibility_off,
                                  color: greycolor,
                                ),
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Select Type".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          Container(
                            height: 60,
                            width: Get.size.width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: DropdownButton(
                              dropdownColor: notifier.background,
                              value: slectStatus,
                              icon: Image.asset(
                                'assets/Arrowdown.png',
                                height: 20,
                                width: 20,
                              ),
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              items: status
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: notifier.textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                               if (value == "SCANNER") {
                                 addManagerController.managerType = "SCANNER";
                                }else if(value == "MANAGER"){
                                 addManagerController.managerType = "MANAGER";
                                }
                                setState(() {
                                  slectStatus = value ?? "";
                                  // listOfUser.add(selectValue);
                                });
                              },
                            ),
                            decoration: BoxDecoration(
                              color: notifier.background,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: notifier.border),
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Select Status".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          Container(
                            height: 60,
                            width: Get.size.width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: DropdownButton(
                              dropdownColor: notifier.background,
                              value: accountSelect,
                              icon: Image.asset(
                                'assets/Arrowdown.png',
                                height: 20,
                                width: 20,
                              ),
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              items: accountStatus
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: notifier.textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == "active") {
                                  addManagerController.accountType = "1";
                                }else if(value == "deactive"){
                                  addManagerController.accountType = "0";
                                }
                                setState(() {
                                  accountSelect = value ?? "";
                                });
                              },
                            ),
                            decoration: BoxDecoration(
                              color: notifier.background,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: notifier.border),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              addManagerController.isLoading ? Center(child: CircularProgressIndicator(),) : SizedBox()
            ],
          );
        }
      ),
    );
  }
}
