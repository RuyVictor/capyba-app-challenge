import 'package:flutter/material.dart';
import 'package:capyba_app/theme/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final Function onPressed;
  final double? width;
  final bool? disabled;
  final IconData? leftIcon;
  final IconData? rightIcon;

  Button(
      {required this.text,
      required this.onPressed,
      this.width,
      this.disabled = false,
      this.leftIcon,
      this.rightIcon});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: disabled!,
        child: Container(
            width: width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: disabled! ? AppColors.DISABLED : AppColors.PRIMARY,
                  elevation: disabled! ? 0 : 4,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (leftIcon != null)
                  Icon(
                    leftIcon,
                    color: AppColors.WHITE,
                    size: 20.0,
                  ),
                  Text(
                  text,
                  style: TextStyle(
                    color: disabled! ? AppColors.SECONDARY : AppColors.WHITE,
                    fontSize: 16,
                  )),
                  if (rightIcon != null)
                  Icon(
                    rightIcon,
                    color: AppColors.WHITE,
                    size: 20.0,
                  )]
              ),
              onPressed: () {
                onPressed();
              },
            )));
  }
}
