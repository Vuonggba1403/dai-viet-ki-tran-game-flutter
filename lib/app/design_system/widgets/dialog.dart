import 'dart:ui';

import 'package:ezwork/app/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showEzWorkConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  bool barrierDismissible = true,
  String? confirmText,
  String? cancelText,
  Future<void> Function()? onConfirm,
  Future<void> Function()? onCancel,
}) async {
  final theme = Theme.of(context);
  cancelText = cancelText ?? 'Cancel';
  final isConfirmed = await showDialog<bool>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(EzWorkSpacing.normal,
              EzWorkSpacing.medium, EzWorkSpacing.normal, EzWorkSpacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.15)),
              const SizedBox(height: EzWorkSpacing.spacing12),
              Text(content, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: EzWorkSpacing.large),
              SizedBox(
                width: double.infinity,
                child: EzWorkPrimaryButton.small(
                  title: confirmText ?? 'Confirm',
                  onPressed: () => context.pop(true),
                ),
              ),
              if (cancelText!.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: EzWorkSpacing.small),
                    child: EzWorkTextButton(
                      title: cancelText,
                      onPressed: () => context.pop(false),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
  if (context.mounted && isConfirmed != null) {
    if (onConfirm != null && isConfirmed) {
      await onConfirm();
    } else if (onCancel != null && !isConfirmed) {
      await onCancel();
    }
  }
}

Future<void> showEzWorkAlertDialog(
  BuildContext context, {
  required String title,
  required String content,
  bool barrierDismissible = true,
  String? buttonText,
  Future<void> Function()? onButtonPressed,
}) async {
  return showEzWorkConfirmDialog(
    context,
    title: title,
    content: content,
    confirmText: buttonText ?? 'Okay',
    cancelText: '',
    onConfirm: onButtonPressed,
    barrierDismissible: barrierDismissible,
  );
}
