import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';

/// Abstract contract for high-level game audio playback.
///
/// Ensures domain logic, combat loops, and Match-3 engines stay completely decoupled
/// from concrete audio engines (FlameAudio, Web Audio API, or platform channels).
abstract interface class GameAudioService {
  /// Prepares audio cache and initial settings without auto-playing.
  Future<void> initialize();

  /// Unlocks the Web Audio Context after the first user gesture.
  Future<void> unlock();

  /// Plays background music loop for [track].
  ///
  /// Must be idempotent: requesting the currently playing track does not restart it.
  Future<void> playBgm(BgmTrack track, {Duration? fade});

  /// Stops any currently playing background music loop.
  Future<void> stopBgm({Duration? fade});

  /// Temporarily pauses the current background music.
  Future<void> pauseBgm();

  /// Resumes the paused background music.
  Future<void> resumeBgm();

  /// Plays a one-shot sound effect cue.
  ///
  /// If muted, drops the request.
  Future<void> playSfx(SfxCue cue, {double volume = 1.0});

  /// Updates audio volume settings and applies them immediately to active playback.
  Future<void> updateSettings(AudioSettings settings);

  /// Releases resources and disposes audio pools/players.
  Future<void> dispose();
}
