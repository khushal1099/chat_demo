import 'dart:io';
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

  static var cu = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String,dynamic>>> getSearchedUser(String value){
    var data = FirebaseFirestore
        .instance
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
}
