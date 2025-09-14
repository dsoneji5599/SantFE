import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';

class AppTextfield extends StatefulWidget {
  final String label;
  final bool? enabled;
  final TextInputType? textInputType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final int minLines;
  final TextStyle? style;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final TextStyle? errorStyle;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final bool isRequired;
  final bool isObscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final Function(String)? onSubmitted;

  const AppTextfield({
    super.key,
    this.label = "",
    this.enabled,
    this.textInputType,
    this.onChanged,
    this.onEditingComplete,
    this.onTap,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.minLines = 1,
    this.style,
    required this.controller,
    this.focusNode,
    this.errorStyle,
    this.errorText,
    this.prefix,
    this.suffix,
    this.hintText,
    this.isRequired = true,
    this.isObscureText = false,
    this.inputFormatters,
    this.fillColor,
    this.onSubmitted,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Text(widget.label, style: AppFonts.outfitBlack),
        const SizedBox(height: 8),
        TextFormField(
          enabled: widget.enabled,
          keyboardType: widget.textInputType,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          readOnly: widget.readOnly,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: widget.style ?? AppFonts.outfitBlack,
          controller: widget.controller,
          focusNode: widget.focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: widget.isObscureText,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            errorStyle: widget.errorStyle,
            errorMaxLines: 3,
            counterText: '',
            prefixIcon: widget.prefix,
            fillColor: widget.fillColor ?? Colors.white.withValues(alpha: 0.1),
            filled: true,
            suffixIcon: widget.suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            hintText: widget.hintText,
            hintStyle: AppFonts.outfitBlack.copyWith(
              color: Colors.grey,
              fontSize: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.borderGrey.withValues(alpha: 0.6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.borderGrey.withValues(alpha: 0.6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorBorderRed,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorBorderRed,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.borderGrey.withValues(alpha: 0.6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (widget.isRequired && (value == null || value.isEmpty)) {
              return "This field can't be empty";
            }
            return widget.errorText;
          },
        ),
      ],
    );
  }
}
