import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import 'chat_model.dart';

class MessageBubble extends StatelessWidget {
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
  Widget build(BuildContext context) => Align(
    alignment:
    isMe ? Alignment.topLeft : Alignment.topRight,
    child: Container(
      decoration: BoxDecoration(
        color: isMe ? WhiteColor : gradient.defoultColor,
        border: Border.all(color: isMe ? Colors.grey.withOpacity(0.3) : Colors.transparent),
        borderRadius: isMe
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
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          isImage
              ? Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(15),
              image: DecorationImage(
                image:
                NetworkImage(message.content),
                fit: BoxFit.cover,
              ),
            ),
          )
              : Text(message.content,
              style:  TextStyle(
                fontSize: 14,
                  fontFamily: FontFamily.gilroyExtraBold,
                  color: isMe ? BlackColor : WhiteColor)),
          const SizedBox(height: 5),
          Text(
            timeago.format(message.sentTime),
            style:  TextStyle(
              color: isMe ? BlackColor : WhiteColor,
              fontFamily:FontFamily.gilroyBold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}
