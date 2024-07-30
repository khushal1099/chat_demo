class MessageModel {
  String? sender;
  String? message;
  bool? seen;
  DateTime? time;

  MessageModel({this.sender, this.message, this.seen, this.time});

  MessageModel.fromMap(Map<String, dynamic> data) {
    sender = data["sender"];
    message = data["message"];
    seen = data["seen"];
    time = data["time"].toDate();
  }

  Map<String, dynamic> data() {
    return {
      "sender": sender,
      "message": message,
      "seen": seen,
      "time": time,
    };
  }
}
