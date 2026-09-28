import 'package:flutter/material.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/Fontfamily.dart';
import '../utils/dark_light_mode.dart';
import 'chat_model.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.isImage,
    required this.message,
  });

  final bool isMe;
  final bool isImage;
  final Message message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

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
    return Align(
      alignment:
      widget.isMe ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isMe ? notifier.background : appcolor,
          border: Border.all(color: widget.isMe ? notifier.border : Colors.transparent),
          borderRadius: widget.isMe
              ? const BorderRadius.only(
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
            topLeft: Radius.circular(13),
          )
              : const BorderRadius.only(
            topRight: Radius.circular(13),
            bottomLeft: Radius.circular(13),
            topLeft: Radius.circular(13),
          ),
        ),
        margin: const EdgeInsets.only(
            top: 10, right: 10, left: 10),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.isMe
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            widget.isImage
                ? Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(15),
                image: DecorationImage(
                  image:
                  NetworkImage(widget.message.content),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Text(
                widget.message.content,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontFamily.gilroyExtraBold,
                    color: widget.isMe ? notifier.textColor : WhiteColor)),
            const SizedBox(height: 5),
            Text(
              timeago.format(widget.message.sentTime),
              style:  TextStyle(
                color: widget.isMe ? notifier.textColor : WhiteColor,
                fontFamily:FontFamily.gilroyBold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
