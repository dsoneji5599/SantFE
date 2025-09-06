import 'package:flutter/material.dart';
import 'package:sant_app/themes/app_fonts.dart';
import 'package:sant_app/widgets/app_scaffold.dart';

class WaitForSant extends StatelessWidget {
  const WaitForSant({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Text(
          "Wait for Admin to Approve your Request",
          style: AppFonts.outfitBlack,
        ),
      ),
    );
  }
}
