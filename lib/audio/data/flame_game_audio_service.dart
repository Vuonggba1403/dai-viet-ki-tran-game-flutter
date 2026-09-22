import 'dart:async';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/game_audio_service.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Concrete [GameAudioService] implementation backed by [FlameAudio] and [AudioPool].
///
/// Features:
/// - Idempotent BGM playback (no restarts on same track).
/// - Concurrency mixing limit (max 8 concurrent SFX with priority dropping).
/// - 50ms throttle on button clicks.
/// - Web Audio unlock protection (queues BGM until first user gesture).
/// - Graceful degradation: all audio exceptions are logged without crashing gameplay.
class FlameGameAudioService implements GameAudioService {
  FlameGameAudioService({AudioSettings? initialSettings})
    : _settings = initialSettings ?? AudioSettings();

  final _logger = Logger('FlameGameAudioService');
  AudioSettings _settings;

  BgmTrack? _currentTrack;
  BgmTrack? _pendingTrack;
  bool _isPaused = false;
  bool _isUnlocked = !kIsWeb; // Non-web platforms start unlocked
  double _duckFactor = 1;

  DateTime? _lastButtonClickTime;

  final Map<SfxCue, AudioPool> _pools = {};
  int _activeSfxCount = 0;
  static const int _maxConcurrentSfx = 8;

  AudioSettings get currentSettings => _settings;
  BgmTrack? get currentTrack => _currentTrack;
  bool get isPaused => _isPaused;
  bool get isUnlocked => _isUnlocked;

  @override
  Future<void> initialize() async {
    try {
      await FlameAudio.bgm.initialize();
      // Pre-create pools for short, frequent SFX
      await _initializeAudioPools();
    } catch (e, stackTrace) {
      _logger.warning('FlameAudio initialization warning', e, stackTrace);
    }
  }

  Future<void> _initializeAudioPools() async {
    try {
      // button_click: 2 players
      _pools[SfxCue.buttonClick] = await FlameAudio.createPool(
        SfxCue.buttonClick.filename,
        maxPlayers: 2,
      );

      // tile_swap: 2 players
      _pools[SfxCue.tileSwap] = await FlameAudio.createPool(
        SfxCue.tileSwap.filename,
        maxPlayers: 2,
      );

      // match_3 and combos: 3 players each
      for (final cue in [
        SfxCue.match3,
        SfxCue.combo2,
        SfxCue.combo3,
        SfxCue.combo4,
        SfxCue.comboMax,
      ]) {
        _pools[cue] = await FlameAudio.createPool(
          cue.filename,
          maxPlayers: 3,
        );
      }

      // enemy_hit and critical_hit: 4 players
      _pools[SfxCue.enemyHit] = await FlameAudio.createPool(
        SfxCue.enemyHit.filename,
        maxPlayers: 4,
      );
      _pools[SfxCue.criticalHit] = await FlameAudio.createPool(
        SfxCue.criticalHit.filename,
        maxPlayers: 4,
      );
    } catch (e, stackTrace) {
      _logger.warning('AudioPool creation warning', e, stackTrace);
    }
  }

  @override
  Future<void> unlock() async {
    if (_isUnlocked) return;
    _isUnlocked = true;
    _logger.info('Web Audio context unlocked via user gesture');

    final trackToPlay = _pendingTrack;
    _pendingTrack = null;
    if (trackToPlay != null) {
      await playBgm(trackToPlay);
    }
  }

  @override
  Future<void> playBgm(BgmTrack track, {Duration? fade}) async {
    // Idempotent: do not restart track if it's already playing
    if (_currentTrack == track && FlameAudio.bgm.isPlaying) {
      return;
    }

    // On Web before user gesture, queue the track
    if (!_isUnlocked) {
      _pendingTrack = track;
      _logger.fine('Queued BGM track "${track.name}" pending audio unlock');
      return;
    }

    _currentTrack = track;
    _pendingTrack = null;
    _isPaused = false;

    try {
      final vol = _calculateEffectiveBgmVolume();
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(track.filename, volume: vol);
    } catch (e, stackTrace) {
      _logger.warning('Failed to play BGM track: ${track.filename}', e, stackTrace);
    }
  }

  @override
  Future<void> stopBgm({Duration? fade}) async {
    _currentTrack = null;
    _pendingTrack = null;
    _isPaused = false;
    try {
      await FlameAudio.bgm.stop();
    } catch (e, stackTrace) {
      _logger.warning('Failed to stop BGM', e, stackTrace);
    }
  }

  @override
  Future<void> pauseBgm() async {
    if (!_isPaused && FlameAudio.bgm.isPlaying) {
      _isPaused = true;
      try {
        await FlameAudio.bgm.pause();
      } catch (e, stackTrace) {
        _logger.warning('Failed to pause BGM', e, stackTrace);
      }
    }
  }

  @override
  Future<void> resumeBgm() async {
    if (_isPaused) {
      _isPaused = false;
      try {
        await FlameAudio.bgm.resume();
        _applyBgmVolume();
      } catch (e, stackTrace) {
        _logger.warning('Failed to resume BGM', e, stackTrace);
      }
    }
  }

  /// Sets ducking factor (e.g. 0.35 on pause, 0.25 on result) and updates active BGM.
  void setBgmDucking(double factor) {
    _duckFactor = factor.clamp(0.0, 1.0);
    _applyBgmVolume();
  }

  /// Restores BGM volume to normal unducked level.
  void restoreBgmVolume() {
    _duckFactor = 1;
    _applyBgmVolume();
  }

  @override
  Future<void> playSfx(SfxCue cue, {double volume = 1.0}) async {
    if (_settings.muted || _settings.effectiveSfxVolume <= 0.0) {
      return;
    }

    // 1. Throttle UI button clicks by 50ms
    if (cue == SfxCue.buttonClick) {
      final now = DateTime.now();
      if (_lastButtonClickTime != null &&
          now.difference(_lastButtonClickTime!).inMilliseconds < 50) {
        return;
      }
      _lastButtonClickTime = now;
    }

    // 2. Concurrency limiting (max 8 concurrent SFX)
    if (_activeSfxCount >= _maxConcurrentSfx) {
      // Lower priority cues get dropped when busy
      if (cue.priority < 50) {
        return;
      }
    }

    final effectiveVol = (_settings.effectiveSfxVolume * volume).clamp(0.0, 1.0);
    if (effectiveVol <= 0.0) return;

    _activeSfxCount++;
    try {
      final pool = _pools[cue];
      if (pool != null) {
        await pool.start(volume: effectiveVol);
      } else {
        await FlameAudio.play(cue.filename, volume: effectiveVol);
      }
    } catch (e, stackTrace) {
      _logger.fine('SFX playback failure (graceful drop): ${cue.filename}', e, stackTrace);
    } finally {
      // Decrement counter after a short safety window
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_activeSfxCount > 0) _activeSfxCount--;
      });
    }
  }

  @override
  Future<void> updateSettings(AudioSettings settings) async {
    _settings = settings;
    _applyBgmVolume();
  }

  void _applyBgmVolume() {
    try {
      final vol = _calculateEffectiveBgmVolume();
      FlameAudio.bgm.audioPlayer.setVolume(vol);
    } catch (e) {
      // Audio player may not be active yet
    }
  }

  double _calculateEffectiveBgmVolume() {
    if (_settings.muted) return 0;
    return (_settings.effectiveMusicVolume * _duckFactor).clamp(0, 1);
  }

  @override
  Future<void> dispose() async {
    try {
      await stopBgm();
      await FlameAudio.bgm.dispose();
      for (final pool in _pools.values) {
        await pool.dispose();
      }
      _pools.clear();
    } catch (e, stackTrace) {
      _logger.warning('FlameAudio dispose error', e, stackTrace);
    }
  }
}
