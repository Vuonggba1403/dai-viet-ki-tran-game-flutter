import 'package:dai_viet_ki_tran_game/audio/data/flame_game_audio_service.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/game_audio_service.dart';
import 'package:flutter/widgets.dart';

/// Application controller owning BGM state, lifecycle transitions, and high-level routing audio events.
class AudioController with WidgetsBindingObserver {
  AudioController({
    required GameAudioService audioService,
  }) : _audioService = audioService {
    WidgetsBinding.instance.addObserver(this);
  }

  final GameAudioService _audioService;

  BgmTrack? _currentTrack;
  bool _isPausedByGame = false;
  bool _isAppInBackground = false;
  bool _hasPlayedResultSound = false;

  BgmTrack? get currentTrack => _currentTrack;
  bool get isPausedByGame => _isPausedByGame;
  GameAudioService get service => _audioService;

  /// Initializes the audio service.
  Future<void> initialize() async {
    try {
      await _audioService.initialize();
    } catch (e, stack) {
      debugPrint('AudioController.initialize failed: $e\n$stack');
    }
  }

  /// Unlocks web audio context upon first user gesture.
  Future<void> unlock() async {
    try {
      await _audioService.unlock();
    } catch (e, stack) {
      debugPrint('AudioController.unlock failed: $e\n$stack');
    }
  }

  /// Requests BGM for the home and shell navigation screens.
  Future<void> enterHome() async {
    try {
      _hasPlayedResultSound = false;
      _isPausedByGame = false;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.restoreBgmVolume();
      }
      await _transitionToTrack(BgmTrack.home);
    } catch (e, stack) {
      debugPrint('AudioController.enterHome failed: $e\n$stack');
    }
  }

  /// Requests BGM for a battle session based on whether a boss is active.
  Future<void> enterBattle({required bool isBoss}) async {
    try {
      _hasPlayedResultSound = false;
      _isPausedByGame = false;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.restoreBgmVolume();
      }
      final targetTrack = isBoss ? BgmTrack.boss : BgmTrack.battle;
      await _transitionToTrack(targetTrack);
    } catch (e, stack) {
      debugPrint('AudioController.enterBattle failed: $e\n$stack');
    }
  }

  /// Handles battle pause overlay (ducks BGM volume to ~35%).
  Future<void> pauseBattle() async {
    try {
      if (_isPausedByGame) return;
      _isPausedByGame = true;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.setBgmDucking(0.35);
      } else {
        await _audioService.pauseBgm();
      }
    } catch (e, stack) {
      debugPrint('AudioController.pauseBattle failed: $e\n$stack');
    }
  }

  /// Restores BGM volume after battle unpause.
  Future<void> resumeBattle() async {
    try {
      if (!_isPausedByGame) return;
      _isPausedByGame = false;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.restoreBgmVolume();
      } else {
        await _audioService.resumeBgm();
      }
    } catch (e, stack) {
      debugPrint('AudioController.resumeBattle failed: $e\n$stack');
    }
  }

  /// Handles combat victory: ducks/stops battle music and plays victory fanfare exactly once.
  Future<void> handleVictory() async {
    try {
      if (_hasPlayedResultSound) return;
      _hasPlayedResultSound = true;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.setBgmDucking(0.20);
      }
      await _audioService.playSfx(SfxCue.victory);
    } catch (e, stack) {
      debugPrint('AudioController.handleVictory failed: $e\n$stack');
    }
  }

  /// Handles combat defeat: ducks/stops battle music and plays defeat cue exactly once.
  Future<void> handleDefeat() async {
    try {
      if (_hasPlayedResultSound) return;
      _hasPlayedResultSound = true;
      final service = _audioService;
      if (service is FlameGameAudioService) {
        service.setBgmDucking(0.20);
      }
      await _audioService.playSfx(SfxCue.defeat);
    } catch (e, stack) {
      debugPrint('AudioController.handleDefeat failed: $e\n$stack');
    }
  }

  /// Plays a one-shot sound effect.
  Future<void> playSfx(SfxCue cue, {double volume = 1.0}) async {
    try {
      await _audioService.playSfx(cue, volume: volume);
    } catch (e, stack) {
      debugPrint('AudioController.playSfx failed: $e\n$stack');
    }
  }

  /// Updates audio settings and passes them to the service.
  Future<void> updateSettings(AudioSettings settings) async {
    try {
      await _audioService.updateSettings(settings);
    } catch (e, stack) {
      debugPrint('AudioController.updateSettings failed: $e\n$stack');
    }
  }

  Future<void> _transitionToTrack(BgmTrack track) async {
    if (_currentTrack == track) {
      // Idempotent: track already playing
      return;
    }
    _currentTrack = track;
    if (!_isAppInBackground) {
      try {
        await _audioService.playBgm(track);
      } catch (e, stack) {
        debugPrint('AudioController._transitionToTrack failed: $e\n$stack');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.hidden:
        case AppLifecycleState.inactive:
          _isAppInBackground = true;
          _audioService.pauseBgm();
        case AppLifecycleState.resumed:
          _isAppInBackground = false;
          if (!_isPausedByGame && _currentTrack != null) {
            _audioService.resumeBgm();
          }
        case AppLifecycleState.detached:
          _isAppInBackground = true;
      }
    } catch (e, stack) {
      debugPrint('AudioController.didChangeAppLifecycleState failed: $e\n$stack');
    }
  }

  /// Disposes controller and removes lifecycle observer.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
  }
}
