import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentTime;
  final MessageType messageType;
  final String userType;

  const Message({
    required this.senderId,
    required this.receiverId,
    required this.sentTime,
    required this.content,
    required this.messageType,
    required this.userType,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        sentTime: json['sentTime'].toDate(),
        content: json['content'],
        messageType:
        MessageType.fromJson(json['messageType']),
        userType: json['userType'] ?? "",
      );

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
    'senderId': senderId,
    'sentTime': sentTime,
    'content': content,
    'messageType': messageType.toJson(),
    'userType': userType,
  };
}

enum MessageType {
  text,
  image;

  String toJson() => name;

  factory MessageType.fromJson(String json) =>
      values.byName(json);
}


class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime lastActive;
  final bool isOnline;

  const UserModel({
    required this.name,
    required this.image,
    required this.lastActive,
    required this.uid,
    required this.email,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(
        uid: json['uid'],
        name: json['name'],
        image: json['image'],
        email: json['email'],
        isOnline: json['isOnline'] ?? false,
        lastActive: json['lastActive'].toDate(),
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'image': image,
    'email': email,
    'isOnline': isOnline,
    'lastActive': lastActive,
  };
}

class FirebaseStorageService {
  static Future<String> uploadImage(
      Uint8List file, String storagePath) async =>
      await FirebaseStorage.instance.ref().child(storagePath).putData(file).then((task) => task.ref.getDownloadURL());
}

