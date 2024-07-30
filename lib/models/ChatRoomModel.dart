import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  String? message;
  String? senderId;
  String? senderEmail;
  String? time;

  ChatModel({
    this.message,
    this.senderId,
    this.senderEmail,
    this.time,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    message: json["message"],
    senderId: json["senderId"],
    senderEmail: json["senderEmail"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "senderId": senderId,
    "senderEmail": senderEmail,
    "time": time,
  };
}
