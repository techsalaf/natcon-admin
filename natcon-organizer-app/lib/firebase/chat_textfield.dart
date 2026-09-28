import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_screens/Api_werper.dart';
import '../api_screens/data_store.dart';
import '../utils/dark_light_mode.dart';
import 'firestore_service.dart';
import 'notification_service.dart';


class ChatTextField extends StatefulWidget {
  const ChatTextField(
      {super.key, required this.receiverId});

  final String receiverId;

  @override
  State<ChatTextField> createState() =>
      _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
   TextEditingController controller = TextEditingController();
  final notificationsService = NotificationsService();

  Uint8List? file;

  @override
  void initState() {
    getDarkMode();
    notificationsService.getReceiverToken(widget.receiverId);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
  Widget build(BuildContext context){
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              controller: controller,
              hintText: 'Add Message...',
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: appcolor,
            radius: 23,
            child: IconButton(
              icon: const Icon(Icons.send,
                  color: Colors.white),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendText(context);
                }else{
                  ApiWrapper.showToastMessage("Please Enter Some Message");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _sendText(BuildContext context) async {
  //   print("szcnbsucbscsb ${widget.receiverId}");
  //   if (controller.text.isNotEmpty) {
  //     await FirebaseFirestoreService.addTextMessage(
  //       receiverId: widget.receiverId,
  //       content: controller.text,
  //     );
  //     // await notificationsService.sendNotification(
  //     //   body: controller.text,
  //     //   senderId: FirebaseAuth.instance.currentUser!.uid,
  //     // );
  //     controller.clear();
  //     FocusScope.of(context).unfocus();
  //   }
  //   FocusScope.of(context).unfocus();
  // }
   Future<void> _sendText(BuildContext context) async {
     print("szcnbsucbscsb ${widget.receiverId}");
     if (controller.text.isNotEmpty) {

       final message = controller.text;
       controller.clear();
       FocusScope.of(context).unfocus();

       await FirebaseFirestoreService.addTextMessage(
         receiverId: widget.receiverId,
         content: message,
       );
       await notificationsService.sendNotification(
         body: message,
         senderId: getData.read("UserLogin")["id"],
       );
     }
   }

}


class MediaService {
  static Future<Uint8List?> pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final file = await imagePicker.pickImage(
          source: ImageSource.gallery);
      if (file != null) {
        return await file.readAsBytes();
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
    return null;
  }
}
final _formKey = GlobalKey<FormState>();


class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
    this.hintText,
    this.onPressedSuffixIcon,
    this.obscureText,
    this.onChanged,
  });

  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final VoidCallback? onPressedSuffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
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
    return Container(
      height: 50,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ?? false,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: notifier.textColor,
          fontFamily: FontFamily.gilroyBold,
          fontSize: 15,
        ),

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "";
          }
          return null;
        },

        decoration: InputDecoration(
          labelText: widget.labelText,
          contentPadding: EdgeInsets.only(top: 10,left: 10),
          hintText: widget.hintText,
          prefixIcon:
          widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          hintStyle: TextStyle(
            color: notifier.textColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
          ),
          errorStyle: TextStyle(fontSize: 0,height: 0),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red),
          ),
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
            onPressed: widget.onPressedSuffixIcon,
            icon: Icon(widget.suffixIcon),
          )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: notifier.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: notifier.border),
          ),
          fillColor: notifier.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: notifier.border),
          ),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:  BorderSide(color: appcolor),
          ),
        ),
      ),
    );
  }
}

