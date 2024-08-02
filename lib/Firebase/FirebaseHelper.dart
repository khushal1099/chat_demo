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
  static const newMsg = 'NewMessages';
  static var newMsgStream;

  Stream<QuerySnapshot<Map<String, dynamic>>> getSearchedUser(String value) {
    var data = FirebaseFirestore.instance
        .collection(users)
        .where("fullname", isEqualTo: value)
        .snapshots();
    return data;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserList(String email) {
    var cu = FirebaseAuth.instance.currentUser;
    print('cu?.email===============> ${cu?.email}');
    var data = FirebaseFirestore.instance
        .collection(users)
        .where('email', isNotEqualTo: email)
        .orderBy('email', descending: false)
        .snapshots();
    return data;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String chatroomId) async {
    var cu = FirebaseAuth.instance.currentUser;
    var data = await FirebaseFirestore.instance
        .collection(users)
        .doc(cu?.uid)
        .collection(chats)
        .doc(chatroomId)
        .collection(messages)
        .orderBy('time', descending: false)
        .limitToLast(20)
        .get();
    return data;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMoreMessages(
      String chatroomId, String msgTime) async {
    var cu = FirebaseAuth.instance.currentUser;
    var data = await FirebaseFirestore.instance
        .collection(users)
        .doc(cu?.uid)
        .collection(chats)
        .doc(chatroomId)
        .collection(messages)
        .where('time', isLessThan: msgTime)
        .orderBy('time', descending: false)
        .limitToLast(20)
        .get();
    return data;
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getNewMsg(
      String chatroomId) async {
    var cu = FirebaseAuth.instance.currentUser;
    var data = FirebaseFirestore.instance
        .collection(users)
        .doc(cu?.uid)
        .collection(chats)
        .doc(chatroomId)
        .collection(newMsg)
        .orderBy('time', descending: false)
        .limitToLast(1)
        .snapshots();
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
        FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
    await storageRef.putFile(File(image));
    final imageUrl = await storageRef.getDownloadURL();
    UserModel userModel = UserModel(
        uid: uid,
        email: email,
        fullname: name,
        profilePic: imageUrl,
        time: DateTime.now().toString());
    await FirebaseFirestore.instance
        .collection(users)
        .doc(uid)
        .update(userModel.toJson());
  }

  Future<void> sendMessage(
    String senderId,
    String senderEmail,
    String message,
    String chatroomId,
    String date,
  ) async {
    var cu = FirebaseAuth.instance.currentUser;
    var doc1 = await FirebaseFirestore.instance
        .collection(users)
        .doc(cu?.uid)
        .collection(chats)
        .doc(chatroomId)
        .get();

    doc1.reference.set({
      "last_msg": message,
      "sender_email": senderEmail,
      "senderId": senderId,
    });

    newMsgStream = doc1.reference
        .collection(newMsg)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(ChatModel(
                message: message,
                senderId: senderId,
                senderEmail: senderEmail,
                time: date)
            .toJson());

    doc1.reference
        .collection(messages)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(ChatModel(
                message: message,
                senderId: senderId,
                senderEmail: senderEmail,
                time: date)
            .toJson());
  }
}
