import 'package:flutter/material.dart';

const largeButtonHeight = 54.0;
const smallButtonHeight = 44.0;

class EzWorkPrimaryButton extends StatelessWidget {
  const EzWorkPrimaryButton.large({
    required this.onPressed,
    required this.title,
    super.key,
  }) : _height = largeButtonHeight;

  const EzWorkPrimaryButton.small({
    required this.onPressed,
    required this.title,
    super.key,
  }) : _height = smallButtonHeight;

  final String title;
  final double _height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          fixedSize: Size.fromHeight(_height),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
      child: FilledButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

class EzWorkTextButton extends StatelessWidget {
  const EzWorkTextButton({
    required this.onPressed,
    required this.title,
    super.key,
  });

  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}

class EzWorkOutlinedButton extends StatelessWidget {
  const EzWorkOutlinedButton.large({
    required this.onPressed,
    required this.title,
    super.key,
  }) : _height = largeButtonHeight;
  const EzWorkOutlinedButton.small({
    required this.onPressed,
    required this.title,
    super.key,
  }) : _height = smallButtonHeight;

  final String title;
  final double _height;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.primary),
        fixedSize: Size.fromHeight(_height),
      ),
      child: Text(title),
    );
  }
}
