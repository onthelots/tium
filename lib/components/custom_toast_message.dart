import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToastMessage({
  required String message,
  Color backgroundColor = Colors.black87,
  ToastGravity gravity = ToastGravity.BOTTOM,
}) {
  Fluttertoast.showToast(
    msg: message,
    gravity: gravity,
    backgroundColor: backgroundColor,
    textColor: Colors.white,
    fontSize: 14,
  );
}