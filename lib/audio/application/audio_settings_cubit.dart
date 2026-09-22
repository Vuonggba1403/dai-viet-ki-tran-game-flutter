import 'package:bloc/bloc.dart';
import 'package:dai_viet_ki_tran_game/audio/application/audio_controller.dart';
import 'package:dai_viet_ki_tran_game/audio/data/audio_settings_repository.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';

/// Cubit managing mutable user audio preferences and syncing with storage and controller.
class AudioSettingsCubit extends Cubit<AudioSettings> {
  AudioSettingsCubit({
    required AudioSettingsRepository repository,
    required AudioController audioController,
  }) : _repository = repository,
       _audioController = audioController,
       super(AudioSettings());

  final AudioSettingsRepository _repository;
  final AudioController _audioController;

  /// Loads initial settings from storage and applies them to audio playback.
  Future<void> loadSettings() async {
    final saved = await _repository.loadSettings();
    emit(saved);
    await _audioController.updateSettings(saved);
  }

  /// Sets master volume [value] in range [0.0, 1.0].
  Future<void> setMasterVolume(double value) async {
    final updated = state.copyWith(masterVolume: value);
    emit(updated);
    await _applyAndPersist(updated);
  }

  /// Sets background music volume [value] in range [0.0, 1.0].
  Future<void> setMusicVolume(double value) async {
    final updated = state.copyWith(musicVolume: value);
    emit(updated);
    await _applyAndPersist(updated);
  }

  /// Sets sound effects volume [value] in range [0.0, 1.0].
  Future<void> setSfxVolume(double value) async {
    final updated = state.copyWith(sfxVolume: value);
    emit(updated);
    await _applyAndPersist(updated);
  }

  /// Toggles global audio mute status.
  Future<void> toggleMute() async {
    final updated = state.copyWith(muted: !state.muted);
    emit(updated);
    await _applyAndPersist(updated);
  }

  Future<void> _applyAndPersist(AudioSettings settings) async {
    await _audioController.updateSettings(settings);
    await _repository.saveSettings(settings);
  }
}
