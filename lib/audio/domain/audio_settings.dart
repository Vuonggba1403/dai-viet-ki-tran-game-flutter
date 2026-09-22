import 'package:meta/meta.dart';

/// Immutable audio preferences configuration with volume clamping.
@immutable
class AudioSettings {
  AudioSettings({
    double masterVolume = 1.0,
    double musicVolume = 0.45,
    double sfxVolume = 0.80,
    this.muted = false,
  }) : masterVolume = masterVolume.clamp(0.0, 1.0),
       musicVolume = musicVolume.clamp(0.0, 1.0),
       sfxVolume = sfxVolume.clamp(0.0, 1.0);

  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool muted;

  /// Effective background music volume accounting for master and mute status.
  double get effectiveMusicVolume =>
      muted ? 0.0 : (masterVolume * musicVolume).clamp(0.0, 1.0);

  /// Effective sound effects volume multiplier accounting for master and mute status.
  double get effectiveSfxVolume =>
      muted ? 0.0 : (masterVolume * sfxVolume).clamp(0.0, 1.0);

  AudioSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? muted,
  }) {
    return AudioSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      muted: muted ?? this.muted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSettings &&
          runtimeType == other.runtimeType &&
          masterVolume == other.masterVolume &&
          musicVolume == other.musicVolume &&
          sfxVolume == other.sfxVolume &&
          muted == other.muted;

  @override
  int get hashCode => Object.hash(masterVolume, musicVolume, sfxVolume, muted);

  @override
  String toString() =>
      'AudioSettings(master: $masterVolume, music: $musicVolume, sfx: $sfxVolume, muted: $muted)';
}
