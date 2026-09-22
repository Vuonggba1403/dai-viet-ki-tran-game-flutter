import 'package:dai_viet_ki_tran_game/audio/application/audio_controller.dart';
import 'package:flutter/widgets.dart';

/// Transparent wrapper detecting the user's first gesture to unlock the Web Audio Context.
class AudioUnlockListener extends StatefulWidget {
  const AudioUnlockListener({
    required this.child,
    required this.audioController,
    super.key,
  });

  final Widget child;
  final AudioController audioController;

  @override
  State<AudioUnlockListener> createState() => _AudioUnlockListenerState();
}

class _AudioUnlockListenerState extends State<AudioUnlockListener> {
  bool _unlocked = false;

  void _handleUserGesture() {
    if (_unlocked) return;
    _unlocked = true;
    widget.audioController.unlock();
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleUserGesture(),
      child: widget.child,
    );
  }
}
