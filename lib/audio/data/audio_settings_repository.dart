import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository responsible for persisting and restoring [AudioSettings] using [SharedPreferencesAsync].
class AudioSettingsRepository {
  AudioSettingsRepository({SharedPreferencesAsync? prefsAsync})
    : _prefs = prefsAsync ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  final _logger = Logger('AudioSettingsRepository');

  static const _keyMasterVolume = 'audio_master_volume';
  static const _keyMusicVolume = 'audio_music_volume';
  static const _keySfxVolume = 'audio_sfx_volume';
  static const _keyMuted = 'audio_muted';

  /// Loads stored audio settings or returns defaults if none exist or on storage error.
  Future<AudioSettings> loadSettings() async {
    try {
      final master = await _prefs.getDouble(_keyMasterVolume);
      final music = await _prefs.getDouble(_keyMusicVolume);
      final sfx = await _prefs.getDouble(_keySfxVolume);
      final muted = await _prefs.getBool(_keyMuted);

      final defaults = AudioSettings();
      return AudioSettings(
        masterVolume: master ?? defaults.masterVolume,
        musicVolume: music ?? defaults.musicVolume,
        sfxVolume: sfx ?? defaults.sfxVolume,
        muted: muted ?? defaults.muted,
      );
    } catch (e, stackTrace) {
      _logger.warning(
        'Failed to load audio settings from storage, using defaults',
        e,
        stackTrace,
      );
      return AudioSettings();
    }
  }

  /// Persists [settings] to asynchronous storage.
  Future<void> saveSettings(AudioSettings settings) async {
    try {
      await Future.wait([
        _prefs.setDouble(_keyMasterVolume, settings.masterVolume),
        _prefs.setDouble(_keyMusicVolume, settings.musicVolume),
        _prefs.setDouble(_keySfxVolume, settings.sfxVolume),
        _prefs.setBool(_keyMuted, settings.muted),
      ]);
    } catch (e, stackTrace) {
      _logger.warning('Failed to persist audio settings', e, stackTrace);
    }
  }
}
