import 'package:flutter/material.dart';

/// Renders a hero character portrait anchored to bottom-center.
class HeroPortrait extends StatelessWidget {
  const HeroPortrait({
    required this.portraitPath,
    this.fallbackColor,
    this.fit = BoxFit.contain,
    super.key,
  });

  final String portraitPath;
  final Color? fallbackColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      portraitPath,
      fit: fit,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.person_rounded,
            size: 64,
            color: fallbackColor ?? Colors.white54,
          ),
        );
      },
    );
  }
}
