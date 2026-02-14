import 'package:flutter/material.dart';

Future<dynamic> navigatorPush(BuildContext context, Widget page) {
  return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

void navigatorPushReplacement(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}
