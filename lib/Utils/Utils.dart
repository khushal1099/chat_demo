import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utils {
  Utils._();

  static Future<void> pageChange(Widget pageName, { Function? onBackScreen}) async {
    await Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => pageName,
        ));
    if (onBackScreen != null) onBackScreen();
  }
}
