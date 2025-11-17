import 'package:flutter/material.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor,
    this.backgroundColor,
    this.padding,
    this.textStyle,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Center(child: CircularProgressIndicator(color: AppColors.appOrange))
        : InkWell(
            onTap: onTap,
            child: Container(
              padding: padding ?? EdgeInsets.all(14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appOrange.withValues(alpha: 0.9),
                    AppColors.appOrange.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style:
                        textStyle ??
                        AppFonts.outfitBlack.copyWith(
                          color: textColor ?? Colors.white,
                        ),
                  ),
                  if (icon != null) SizedBox(width: 8),
                  if (icon != null) icon!,
                ],
              ),
            ),
          );
  }
}
