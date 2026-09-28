import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../Api/data_store.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
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
  final controller = TextEditingController();
  final notificationsService = NotificationsService();
  final _formKey = GlobalKey<FormState>();

  Uint8List? file;

  @override
  void initState() {
    notificationsService.getReceiverToken(widget.receiverId);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => Form(
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
          backgroundColor: gradient.defoultColor,
          radius: 23,
          child: IconButton(
            icon: const Icon(Icons.send,
                color: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                 _sendText(context);
              } else {
                showToastMessage("Please Enter Some Message");
              }
            },
          ),
        ),
      ],
    ),
  );

  // Future<void> _sendText(BuildContext context) async {
  //   print("++++++++++++ ${widget.receiverId}");
  //   if (controller.text.isNotEmpty) {
  //     await FirebaseFirestoreService.addTextMessage(
  //       receiverId: widget.receiverId,
  //       content: controller.text,
  //     );
  //     controller.clear();
  //     await notificationsService.sendNotification(
  //       body: controller.text,
  //       senderId: FirebaseAuth.instance.currentUser!.uid,
  //     );
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

  // Future<void> _sendImage() async {
  //   final pickedImage = await MediaService.pickImage();
  //   setState(() => file = pickedImage);
  //   if (file != null) {
  //     await FirebaseFirestoreService.addImageMessage(
  //       receiverId: widget.receiverId,
  //       file: file!,
  //     );
  //     // await notificationsService.sendNotification(
  //     //   body: 'image........',
  //     //   senderId: FirebaseAuth.instance.currentUser!.uid,
  //     // );
  //   }
  // }
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



class CustomTextFormField extends StatelessWidget {
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
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      onChanged: onChanged,
      style: TextStyle(
        color: BlackColor,
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
        labelText: labelText,
        hintText: hintText,
        contentPadding: const EdgeInsets.only(top: 10,left: 10),
          hintStyle: const TextStyle(
            color: Colors.black,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
          ),
        prefixIcon:
        prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          onPressed: onPressedSuffixIcon,
          icon: Icon(suffixIcon),
        )
            : null,
        errorStyle: const TextStyle(fontSize: 0,height: 0),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
        ),
        fillColor: WhiteColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
        ),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:  const BorderSide(color: gradient.defoultColor),
        ),
      ),
    ),
  );
}

