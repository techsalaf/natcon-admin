import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Api/data_store.dart';
import 'chat_model.dart';



class FirebaseFirestoreService {
  static final firestore = FirebaseFirestore.instance;

  static Future<void> createUser({
    required String name,
    required String image,
    required String email,
    required String uid,
  }) async {

    final user = UserModel(
      uid: uid,
      email: email,
      name: name,
      image: image,
      isOnline: true,
      lastActive: DateTime.now(),
    );

    List ids = [getData.read("UserLogin")["id"], uid];
    ids.sort();
    String chatRoomId = ids.join("_");

    await firestore.collection('Magic_Organization_rooms').doc(uid).set(user.toJson());
  }

  static Future<void> addTextMessage({required String content, required String receiverId,}) async {
    final message = Message(content: content, sentTime: DateTime.now(), receiverId: receiverId, messageType: MessageType.text, senderId: getData.read("UserLogin")["id"],userType: "US");
    await _addMessageToChat(receiverId, message);
  }

  static Future<void> addImageMessage({required String receiverId, required Uint8List file,}) async {
    final image = await FirebaseStorageService.uploadImage(
        file, 'image/chat/${DateTime.now()}');

    final message = Message(content: image, sentTime: DateTime.now(), receiverId: receiverId, messageType: MessageType.image, senderId: getData.read("UserLogin")["id"],userType: "US"
    );
    await _addMessageToChat(receiverId, message);
  }

  static Future<void> _addMessageToChat(String receiverId, Message message,) async {

    String conID = "${getData.read("UserLogin")["id"]}_$receiverId";

    Timestamp timestamp = Timestamp.now();

    // await firestore.collection("Magic_Organization_rooms").doc(getData.read("UserLogin")["id"]).set({"timeStamp": timestamp});
    // await firestore.collection("Magic_Organization_rooms").doc(receiverId).set({"timeStamp": timestamp});
    // await firestore.collection('Magic_Organization_rooms').doc(receiverId).collection('chat').doc(getData.read("UserLogin")["id"]).set({"timeStamp": timestamp});
    // await firestore.collection('Magic_Organization_rooms').doc(getData.read("UserLogin")["id"]).collection('chat').doc(receiverId).set({"timeStamp": timestamp});
    await firestore.collection('Magic_Organization_rooms').doc(conID).set({"timeStamp": timestamp});

    await firestore.collection('Magic_Organization_rooms').doc(conID).collection('messages').add(message.toJson());

    // await firestore.collection('Magic_Organization_rooms').doc(getData.read("UserLogin")["id"]).collection('chat').doc(receiverId).collection('messages').add(message.toJson());
    // await firestore.collection('Magic_Organization_rooms').doc(receiverId).collection('chat').doc(getData.read("UserLogin")["id"]).collection('messages').add(message.toJson());

  }

  static Future<void> updateUserData(
      Map<String, dynamic> data) async =>
      await firestore.collection('Magic_Organization_rooms').doc(getData.read("UserLogin")["id"]).update(data);

  static Future<List<UserModel>> searchUser(String name) async {
    final snapshot = await FirebaseFirestore.instance.collection('Magic_Organization_rooms').where("name", isGreaterThanOrEqualTo: name).get();

    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Stream<QuerySnapshot> getMessage(
      {required String userId, required String otherUserId}) {
    List ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return firestore.collection("Magic_Organization_rooms").doc(chatRoomId).collection('messages').snapshots();
  }
}

