import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:capyba_app/theme/colors.dart';

class DefaultInput extends StatelessWidget {
  final bool? autofocus;
  final Color? color;
  final TextEditingController controller;
  final bool? enabled;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? label;
  final bool? obscureText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final TextCapitalization? textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final int? maxLines;
  final bool? iconLeft;
  final Function()? onIconTap;
  final int? maxLength;
  final bool? readOnly;

  DefaultInput({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.color,
    this.icon,
    this.onChanged,
    this.autofocus = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.maxLines,
    this.iconLeft,
    this.onIconTap,
    this.maxLength,
    this.readOnly,
  });

  // Styles

  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(60));
  final OutlineInputBorder errorBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 4),
    borderRadius: borderRadius,
  );
  final OutlineInputBorder outBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(40, 0, 0, 0), width: 1),
    borderRadius: borderRadius,
  );
  final OutlineInputBorder focusedBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255, 179, 217, 255), width: 3),
    borderRadius: borderRadius,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 10),
          child: Text(label ?? '', style: TextStyle(color: AppColors.WHITE),)),
      TextFormField(
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: textCapitalization as TextCapitalization,
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus as bool,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText as bool,
        autovalidateMode: autovalidateMode,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        onChanged: onChanged,
        decoration: InputDecoration(
          suffixIcon: iconLeft != null || icon == null ? null : _buildIcon(),
          prefixIcon: iconLeft != null || icon == null ? null : _buildIcon(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            fontSize: 15,
          ),
          errorStyle: TextStyle(
            fontSize: 13.0,
            color: Colors.red[200],
            fontWeight: FontWeight.bold,
          ),
          errorMaxLines: 2,
          labelStyle: TextStyle(color: color ?? AppColors.BLACK),
          enabledBorder: outBorder,
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
              borderRadius: borderRadius),
          focusedBorder: focusedBorder,
          border: outBorder,
        ),
        onTap: onTap,
      )
    ]));
  }

  GestureDetector _buildIcon() {
    return GestureDetector(
        onTap: onIconTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            icon,
            color: AppColors.SECONDARY,
          ),
        ));
  }
}
