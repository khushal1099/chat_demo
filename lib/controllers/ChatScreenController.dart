import 'package:get/get.dart';

class ChatScreenController extends GetxController {
  String? uid;
  String? email;
  String? fullname;
  String? profilePic;
  String? time;
  RxBool isSend = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      uid = Get.arguments['uid'];
      email = Get.arguments['email'];
      fullname = Get.arguments['fullname'];
      profilePic = Get.arguments['profilePic'];
      time = Get.arguments['time'];
    }
  }
}
