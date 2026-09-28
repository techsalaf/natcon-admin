// ignore_for_file: non_constant_identifier_names, camel_case_types, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, file_names, must_be_immutable, use_key_in_widget_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_light_mode.dart';

Widget passwordtextfield({context,Widget? suffixIcon,
    prefixIcon,
  bool? fill,
    String? lebaltext,
    double? width,
  Color? fillColor,
  String? hint,
    bool? obscureText,
    String? Function(String?)? validator,
    TextEditingController? controller}) {
  notifier = Provider.of<ColorNotifier>(context, listen: true);
  return Container(
    width: width,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText!,
      readOnly: false,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        fontFamily: "Gilroy Medium",
        color: notifier.textColor,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: fill,
        fillColor: fillColor,
        labelText: lebaltext,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appcolor),
          borderRadius: BorderRadius.circular(15),
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: notifier.border,
            ),
            borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

AppButton(
    {Function()? onTap,
    String? buttontext,
    double? width,
    Color? buttonColor,
    textcolor,
    Gradient? gradientcolor,
    EdgeInsetsGeometry? margin1,
    BoxBorder? border}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: margin1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: gradientcolor,
          border: border,
          color: buttonColor),
      height: 50,
      width: width,
      child: Center(
          child: Text(buttontext!,
              style: TextStyle(
                  color: textcolor, fontFamily: "Gilroy Bold", fontSize: 16))),
    ),
  );
}

dottedline({double? lineLength}) {
  return DottedLine(
      direction: Axis.horizontal,
      lineLength: lineLength!,
      lineThickness: 1.0,
      dashColor: greycolor,
      dashGapLength: 4.0);
}

class gradient {
  static const Gradient btnGradient = LinearGradient(
    colors: [Color(0xff0039C4), Color(0xff6071FF)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xff5bd80e), Color.fromARGB(255, 100, 199, 64)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xffdaedfd), Color(0xffdaedfd)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Gradient cancleGradient = LinearGradient(
    colors: [Color(0xffBA021C), Color(0xffE1495E)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Gradient completeGradient = LinearGradient(
    colors: [Color(0xff008A21), Color(0xff07DF3A)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static const Color defoultColor = Color(0xff0c82df);
}

GestButton(
    {String? buttontext,
    Function()? onclick,
    double? Width,
    double? height,
    Color? buttoncolor,
    EdgeInsets? margin,
    TextStyle? style,
    Gradient? gradient}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: height,
      width: Width,
      // margin: EdgeInsets.only(top: 15, left: 30, right: 30),
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: buttoncolor,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 1,
          ), //BoxShadow
        ],
      ),
      child: Text(buttontext!, style: style),
    ),
  );
}
var currency;
// var
var AccountType = getData.read("AccountType");

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

CustomAppbar({context,String? title, Function()? onTap}) {
  notifier = Provider.of<ColorNotifier>(context, listen: true);
  return AppBar(
    leading: InkWell(
      onTap: () {
        Get.back();
      },
      child: Icon(
        Icons.arrow_back,
        color: notifier.textColor,
      ),
    ),
    centerTitle: true,
    title: Text(
      title!,
      maxLines: 2,
      style: TextStyle(
        fontSize: 16,
        fontFamily: FontFamily.gilroyBold,
        color: notifier.textColor,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    elevation: 0,
    backgroundColor: notifier.background,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 45,
            width: 45,
            child: Icon(
              Icons.add,
              color: WhiteColor,
            ),
            decoration: BoxDecoration(
              gradient: gradient.btnGradient,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ],
  );
}

textfield(
    {String? type,
    labelText,
    prefixtext,
    suffix,
    Color? labelcolor,
    prefixcolor,
    floatingLabelColor,
    focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
      Widget? Suffix,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    void Function()? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    Height}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 10,
      ),
      Text(
        type ?? "",
        style: TextStyle(
          fontFamily: FontFamily.gilroyBold,
          fontSize: 16,
          color: notifier.textColor,
        ),
      ),
      SizedBox(height: Get.height * 0.01),
      Container(
        height: Height,
        width: Width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: notifier.background),
        child: TextFormField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          cursorColor: notifier.textColor,
          keyboardType: textInputType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: max,
          readOnly: readOnly ?? false,
          inputFormatters: inputFormatters,
          style: TextStyle(
              color: notifier.textColor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18),
          decoration: InputDecoration(
            hintText: labelText,
            suffix: suffix,
            hintStyle: TextStyle(
                color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: appcolor),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: notifier.border),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: notifier.border),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: validator,
        ),
      ),
    ],
  );
}

textfield1(
    {String? type,
    labelText,
    prefixtext,
    suffix,
    Color? labelcolor,
    prefixcolor,
    floatingLabelColor,
    focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    Height}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        type ?? "",
        style: TextStyle(
          fontFamily: FontFamily.gilroyBold,
          fontSize: 16,
          color: BlackColor,
        ),
      ),
      SizedBox(height: Get.height * 0.01),
      Container(
        height: Height,
        width: Width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: greycolor,
        ),
        child: TextFormField(
          controller: controller,
          onChanged: onChanged,
          cursorColor: BlackColor,
          keyboardType: textInputType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: max,
          readOnly: readOnly ?? false,
          inputFormatters: inputFormatters,
          style: TextStyle(
              color: BlackColor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18),
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: TextStyle(
                color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: greycolor),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: greycolor),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: greycolor),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: validator,
        ),
      ),
    ],
  );
}

appbar({String? title, List<Widget>? action}) {
  return AppBar(
    leading: InkWell(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            "assets/arrowleft.png",
            color: notifier.textColor,
          ),
        )),
    centerTitle: false,
    elevation: 0,
    backgroundColor: notifier.background,
    title: Text(
      title!,
      style: TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 16,
        color: notifier.textColor,
      ),
    ),
    actions: action,
  );
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

orderbutton(
    {String? text, Color? buttoncolor, Function()? onTap, Gradient? gradient}) {
  return InkWell(
    onTap: onTap,
    child: Container(
        height: 40,
        width: Get.width * 0.44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(50),
            color: buttoncolor),
        child: Text(
          text!,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: WhiteColor,
          ),
        )),
  );
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

appbarmenu({String? image, Function()? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 42,
      width: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgcolor),
      child: Image.asset(
        image!,
        height: 20,
        width: 20,
        color: BlackColor,
      ),
    ),
  );
}

profilemenu(
    {String? image,
    title,
    Function()? onTap,
    Color? bgcolor,
    imagecolor,
    titlecolor,
    arrowcolor}) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: bgcolor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(image!, color: imagecolor, height: 25, width: 25),
                  SizedBox(width: Get.width * 0.03),
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: titlecolor),
                  ),
                ],
              ),
              Image.asset("assets/Vector.png",
                  color: Greycolor, height: 18, width: 18)
            ],
          ),
        ),
      ),
      SizedBox(height: Get.height * 0.02)
    ],
  );
}

List<String> eventname = [
  "Add Event",
  "Event Types",
  "Cover Images",
  "Event Gallery",
  "Event Artist",
  "Event Promo",
  "My Earning",
  "My Payout",
  "Check In",
];
