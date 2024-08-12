import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utils {
  Utils._();

  static Future<void> pageChange(Widget pageName,
      {Function? onBackScreen}) async {
    await Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => pageName,
      ),
    );
    if (onBackScreen != null) onBackScreen();
  }

  static void print(dynamic data, {String tag = 'tag'}) {
    String s = '';
    s = '$s\n========================== $tag ==========================\n\n';
    s = '$s$data';
    s = '$s\n\n====================================================\n';
    log(s);
  }
}
