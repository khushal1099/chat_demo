// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? uid;
  String? email;
  String? fullname;
  String? profilePic;
  String? time;
  String? fcmToken;  // Added fcmToken

  UserModel({
    this.uid,
    this.email,
    this.fullname,
    this.profilePic,
    this.time,
    this.fcmToken,  // Added fcmToken
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json["uid"],
    email: json["email"],
    fullname: json["fullname"],
    profilePic: json["profilePic"],
    time: json["time"],
    fcmToken: json["fcmToken"],  // Added fcmToken
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "fullname": fullname,
    "profilePic": profilePic,
    "time": time,
    "fcmToken": fcmToken,  // Added fcmToken
  };
}
