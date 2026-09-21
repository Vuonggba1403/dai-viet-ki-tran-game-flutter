import 'package:flutter/material.dart';

class LoadingOverlayController extends ChangeNotifier {
  factory LoadingOverlayController() => _instance;
  LoadingOverlayController._singleton();
  static final LoadingOverlayController _instance =
      LoadingOverlayController._singleton();

  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }
}
