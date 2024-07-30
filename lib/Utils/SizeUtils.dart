import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SizeUtils {
  SizeUtils._();

  static double height = 0.0;
  static double width = 0.0;

  static config(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}
