import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

Container toastContainer({required String type, required String text}) {
  return Container(
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.symmetric(horizontal: 40.0),
    decoration: BoxDecoration(
      boxShadow: const [
        BoxShadow(color: Color.fromARGB(60, 0, 0, 0), blurRadius: 4)
      ],
      borderRadius: BorderRadius.circular(5.0),
      color: type == 'sucess'
          ? Colors.green[600]
          : type == 'warning'
              ? Colors.orange[600]
              : Colors.red[600],
    ),
    child: Row(
      children: [
        Icon(
          type == 'sucess'
              ? Icons.check_circle
              : type == 'warning'
                  ? Icons.warning_rounded
                  : Icons.dangerous_rounded,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: Text(
            text,
            style: const TextStyle(
            color: Colors.white,
          ),
        )),
        InkWell(
          onTap: () {
            ToastManager().dismissAll(showAnim: true);
          },
          child: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ),
  );
}

class Toast {
  showSucess(BuildContext context, String text) {
    showToastWidget(
      toastContainer(text: text, type: 'sucess'),
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      reverseCurve: Curves.decelerate,
      reverseAnimation: StyledToastAnimation.slideFromTop,
      curve: Curves.decelerate,
      isIgnoring: false,
    );
  }

  showWarning(BuildContext context, String text) {
    showToastWidget(
      toastContainer(text: text, type: 'warning'),
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      reverseCurve: Curves.decelerate,
      reverseAnimation: StyledToastAnimation.slideFromTop,
      curve: Curves.decelerate,
      isIgnoring: false,
    );
  }

  showDanger(BuildContext context, String text) {
    showToastWidget(
      toastContainer(text: text, type: 'danger'),
      context: context,
      position: StyledToastPosition.top,
      animation: StyledToastAnimation.slideFromTop,
      reverseCurve: Curves.decelerate,
      reverseAnimation: StyledToastAnimation.slideFromTop,
      curve: Curves.decelerate,
      isIgnoring: false,
    );
  }
}
