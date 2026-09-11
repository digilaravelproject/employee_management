import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class AppInputField extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool obscure;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final IconData? icon;
  final double iconSize;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final String? phoneCode;
  final VoidCallback? onPhoneCodeTap;
  final bool isRequired;
  final String? errorText;
  final bool autoFocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppInputField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscure = false,
    this.obscureText,
    this.prefixIcon,
    this.prefix,
    this.icon,
    this.iconSize = 20,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.phoneCode,
    this.onPhoneCodeTap,
    this.isRequired = false,
    this.errorText,
    this.autoFocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_errorText != null && widget.validator != null) {
      final result = widget.validator!(widget.controller?.text);
      if (result != _errorText) {
        setState(() {
          _errorText = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AppText(
            widget.label!,
            style: AppTextStyle.body,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          autofocus: widget.autoFocus,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          obscureText: widget.obscureText ?? (widget.isPassword || widget.obscure),
          validator: (val) {
            if (widget.validator != null) {
              final result = widget.validator!(val);
              setState(() {
                _errorText = result;
              });
              return result;
            }
            return null;
          },
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: widget.enabled ? AppColors.slate50 : AppColors.slate100.withValues(alpha: 0.5),
            
            // Default Border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: (widget.errorText != null || _errorText != null) ? AppColors.errorColor : AppColors.slate200, width: 1),
            ),
            
            // Focused Border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: (widget.errorText != null || _errorText != null) ? AppColors.errorColor : AppColors.primaryColor, width: 1.5),
            ),
            
            // Error Border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.errorColor, width: 1),
            ),
            
            // Focused Error Border
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
            ),
            
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.slate200.withValues(alpha: 0.5), width: 1),
            ),

            prefixIcon: (widget.phoneCode != null || widget.prefixIcon != null || widget.icon != null)
                ? Container(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.phoneCode != null) ...[
                    GestureDetector(
                      onTap: widget.onPhoneCodeTap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: AppColors.primaryColor, size: widget.iconSize),
                            const SizedBox(width: 8),
                          ],
                          AppText(
                            widget.phoneCode!,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textColorSecondary),
                          const SizedBox(width: 4),
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.slate200,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ] else
                    IconTheme(
                      data: IconThemeData(color: AppColors.primaryColor, size: widget.iconSize),
                      child: widget.prefixIcon ?? Icon(widget.icon),
                    ),
                ],
              ),
            )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            prefix: widget.prefix,
            suffixIcon: widget.suffixIcon != null
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconTheme(
                data: const IconThemeData(color: AppColors.textColorHint, size: 20),
                child: widget.suffixIcon!,
              ),
            )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 48),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            contentPadding: EdgeInsets.only(
              left: (widget.prefixIcon != null || widget.icon != null || widget.prefix != null) ? 0 : 20,
              right: 20,
              top: 16,
              bottom: 16,
            ),
          ),
        ),
        if (_errorText != null || widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: AppText(
              _errorText ?? widget.errorText!,
              color: AppColors.errorColor,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}