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

  UserModel({
    this.uid,
    this.email,
    this.fullname,
    this.profilePic,
    this.time,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json["uid"],
    email: json["email"],
    fullname: json["fullname"],
    profilePic: json["profilePic"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "fullname": fullname,
    "profilePic": profilePic,
    "time": time,
  };
}
