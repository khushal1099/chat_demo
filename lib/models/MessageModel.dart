// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  String? sender;
  String? message;
  bool? seen;
  String? time;

  MessageModel({
    this.sender,
    this.message,
    this.seen,
    this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    sender: json["sender"],
    message: json["message"],
    seen: json["seen"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "sender": sender,
    "message": message,
    "seen": seen,
    "time": time,
  };
}
