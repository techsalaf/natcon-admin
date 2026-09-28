import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../api_screens/data_store.dart';
import '../utils/Colors.dart';
import '../utils/dark_light_mode.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  int? _value = 0;


  final List locale = [
    {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
    {'name': 'عربى', 'locale': const Locale('ar', 'IN')},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
    {'name': 'Gujarati', 'locale': const Locale('gu', 'GUJARATI')},
    {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
    {'name': 'French', 'locale': const Locale('fr', 'ES')},
    {'name': 'Germany', 'locale': const Locale('de', 'ES')},
    {'name': 'Indonesia', 'locale': const Locale('in', 'ES')},
    // **********************************************************
    {'name': 'South Africa', 'locale': const Locale('ZA', 'ES')},
    {'name': 'Turkish', 'locale': const Locale('tr', 'ES')},
    {'name': 'Portuguese', 'locale': const Locale('pt', 'ES')},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    save("lan1", locale.countryCode);
    save("lan2", locale.languageCode);
    Get.updateLocale(locale);
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifier.textColor,
          ),
        ),
        title: Text(
          "Language".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Gilroy Bold",
            color: notifier.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Text(
                  "Suggested".tr,
                  style: TextStyle(
                    fontSize: 17,
                    color: notifier.textColor,
                    fontFamily: "Gilroy Bold",
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              ListView.builder(
                itemCount: locale.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _value = index;
                        save("lanValue", _value);
                        updateLanguage(locale[index]['locale']);
                      });
                    },
                    child: languageWidget(
                      name: locale[index]['name'],
                      color: greycolor.withOpacity(0.5),
                      value: index,
                      radio: Radio(
                        value: index,
                        fillColor: WidgetStatePropertyAll(appcolor),
                        groupValue: getData.read("lanValue") != null
                            ? getData.read("lanValue")
                            : _value,
                        hoverColor: appcolor,
                        onChanged: (value4) {
                          setState(() {
                            _value = index;
                            save("lanValue", _value);
                            updateLanguage(locale[index]['locale']);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget languageWidget({String? name, int? value, void Function(int?)? onChanged, radio,required Color color}) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(left: 15,right: 15),
        child: Row(
          children: [
            Text(
              name ?? "",
              style: TextStyle(
                fontFamily: "Gilroy Medium",
                fontSize: 16,
                color: notifier.textColor,
              ),
            ),
            Spacer(),
            radio,
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: notifier.background,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

}




