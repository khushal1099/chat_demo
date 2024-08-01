import 'dart:io';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FBHelper {
  static final FBHelper _obj = FBHelper._();

  FBHelper._();

  factory FBHelper() {
    return _obj;
  }

  static const users = 'Users';
  static const chats = 'Chats';
  static const messages = 'Messages';

  static var cu = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> getSearchedUser(String value) {
    var data = FirebaseFirestore.instance
        .collection(users)
        .where("fullname", isEqualTo: value)
        .snapshots();
    return data;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserList(String email) {
    var data = FirebaseFirestore.instance
        .collection(users)
        .where('email', isNotEqualTo: email)
        .orderBy('email', descending: false)
        .snapshots();
    return data;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatroomId) async {
    var data = await FirebaseFirestore.instance
        .collection(FBHelper.chats)
        .doc(chatroomId)
        .collection(FBHelper.messages)
        .orderBy('time', descending: false)
        .limitToLast(20)
        .get();
    return data;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMoreMessages(String chatroomId,String msgTime) async {
    var data = await FirebaseFirestore.instance
        .collection(FBHelper.chats)
        .doc(chatroomId)
        .collection(FBHelper.messages)
        .where('time', isLessThan: msgTime)
        .orderBy('time', descending: false)
        .limitToLast(20)
        .get();
    return data;
  }

  Future<void> loginUser(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  Future<void> signUpUser(String email, String password) async {
    var user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    var uid = user.user!.uid;
    UserModel userModel = UserModel(
        uid: uid,
        email: email,
        fullname: '',
        profilePic: '',
        time: DateTime.now().toString());
    await FirebaseFirestore.instance
        .collection(users)
        .doc(uid)
        .set(userModel.toJson());
  }

  Future<void> completeUserProfile(
      String image, String name, String uid, String email) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('user_images').child('${uid}.jpg');
    await storageRef.putFile(File(image));
    final imageUrl = await storageRef.getDownloadURL();
    UserModel userModel = UserModel(
        uid: uid,
        email: email,
        fullname: name,
        profilePic: imageUrl,
        time: DateTime.now().toString());
    await FirebaseFirestore.instance
        .collection(users) // Ensure 'users' is the correct collection name
        .doc(uid)
        .update(userModel.toJson());
  }

  Future<void> sendMessage(
      String senderId,
      String receiverId,
      String senderEmail,
      String receiverEmail,
      String message,
      String receiverName,
      String senderName,
      String senderImage,
      String receiverImage) async {
    var doc1 = await FirebaseFirestore.instance
        .collection(chats)
        .doc("$senderId-$receiverId")
        .get();

    var doc2 = await FirebaseFirestore.instance
        .collection(chats)
        .doc("$receiverId-$senderId")
        .get();

    doc1.reference.set({
      "last_msg": message,
      "sender_email": senderEmail,
      "receiver_email": receiverEmail,
      "senderId": senderId,
      "receiverId": receiverId,
      "receiver_name": receiverName,
      "sender_name": senderName,
      "sender_image": senderImage,
      "receiver_image": receiverImage
    });

    doc2.reference.set({
      "last_msg": message,
      "sender_email": receiverEmail,
      "receiver_email": senderEmail,
      "senderId": receiverId,
      "receiverId": senderId,
      "receiver_name": senderName,
      "sender_name": receiverName,
      "sender_image": receiverImage,
      "receiver_image": senderImage
    });

    doc1.reference
        .collection(messages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(ChatModel(
                message: message,
                senderId: senderId,
                senderEmail: senderEmail,
                time: "${DateTime.now()}")
            .toJson());

    doc2.reference
        .collection(messages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(ChatModel(
                message: message,
                senderId: senderId,
                senderEmail: senderEmail,
                time: "${DateTime.now()}")
            .toJson());
  }

  Future<ChatModel> chatData(String chatroomId) async {
    var data = await FirebaseFirestore.instance
        .collection(FBHelper.chats)
        .doc(chatroomId)
        .get();

    var chatData = ChatModel.fromJson(data.data() as Map<String, dynamic>);
    return chatData;
  }
}
