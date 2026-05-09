import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

abstract final class DisplayService {
  static void showToast(
    BuildContext context, {
    required String title,
    required String message,
    ToastificationType type = ToastificationType.info,
  }) {
    toastification.show(
      context: context,
      type: type,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      style: ToastificationStyle.fillColored,
    );
  }
}
