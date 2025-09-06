import 'package:flutter/material.dart';
import 'package:sant_app/themes/app_colors.dart';
import 'package:sant_app/themes/app_fonts.dart';

class AppDropdown<T> extends StatefulWidget {
  final String label;
  final bool? enabled;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? errorText;
  final TextStyle? errorStyle;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final bool isRequired;

  const AppDropdown({
    super.key,
    this.label = "",
    this.enabled,
    this.onChanged,
    this.onTap,
    this.value,
    required this.items,
    this.errorStyle,
    this.errorText,
    this.prefix,
    this.suffix,
    this.hintText,
    this.isRequired = true,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _errorText = widget.errorText;
  }

  void _validateField() {
    setState(() {
      if (widget.isRequired && widget.value == null) {
        _errorText = "This field can't be empty";
      } else {
        _errorText = widget.errorText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Text(widget.label, style: AppFonts.outfitBlack),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _errorText != null
                  ? AppColors.errorBorderRed
                  : AppColors.borderGrey.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.enabled == false
                ? null
                : (T? newValue) {
                    widget.onChanged?.call(newValue);
                    _validateField();
                  },
            onTap: widget.onTap,
            style: AppFonts.outfitBlack,
            decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              counterText: '',
              prefixIcon: widget.prefix,
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
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            isExpanded: true,
            validator: (value) {
              if (widget.isRequired && value == null) {
                return "This field can't be empty";
              }
              return widget.errorText;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              _errorText!,
              style:
                  widget.errorStyle ??
                  TextStyle(color: AppColors.errorBorderRed, fontSize: 12),
              maxLines: 3,
            ),
          ),
      ],
    );
  }
}
