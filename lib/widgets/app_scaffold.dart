import 'package:flutter/material.dart';
import 'package:sant_app/themes/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.scaffoldKey,
    this.drawer,
  });
  final AppBar? appBar;
  final Widget body;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      drawer: drawer,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.appOrange, Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: body,
      ),
    );
  }
}
