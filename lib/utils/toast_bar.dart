import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final messangerKey = GlobalKey<ScaffoldMessengerState>();

void toastMessage(String message, {String? title, bool? isSuccess = true}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16,
  );
}
