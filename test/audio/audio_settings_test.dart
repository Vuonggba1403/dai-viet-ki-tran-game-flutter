import 'package:dai_viet_ki_tran_game/audio/data/audio_settings_repository.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioSettings & Persistence Tests', () {
    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('9. AudioSettings automatically clamps volume values between 0.0 and 1.0', () {
      final settingsOver = AudioSettings(
        masterVolume: 2.5,
        musicVolume: 1.2,
        sfxVolume: 99,
      );
      expect(settingsOver.masterVolume, equals(1));
      expect(settingsOver.musicVolume, equals(1));
      expect(settingsOver.sfxVolume, equals(1));

      final settingsUnder = AudioSettings(
        masterVolume: -0.5,
        musicVolume: -10,
        sfxVolume: -0.01,
      );
      expect(settingsUnder.masterVolume, equals(0.0));
      expect(settingsUnder.musicVolume, equals(0.0));
      expect(settingsUnder.sfxVolume, equals(0.0));
    });

    test('10. AudioSettingsRepository persists and restores audio preferences', () async {
      final repo = AudioSettingsRepository();

      // Initially loads defaults
      final initial = await repo.loadSettings();
      expect(initial.masterVolume, equals(1.0));
      expect(initial.musicVolume, equals(0.45));
      expect(initial.sfxVolume, equals(0.80));
      expect(initial.muted, isFalse);

      // Save custom settings
      final custom = AudioSettings(
        masterVolume: 0.75,
        musicVolume: 0.30,
        sfxVolume: 0.60,
        muted: true,
      );
      await repo.saveSettings(custom);

      // Restore and verify
      final restored = await repo.loadSettings();
      expect(restored.masterVolume, equals(0.75));
      expect(restored.musicVolume, equals(0.30));
      expect(restored.sfxVolume, equals(0.60));
      expect(restored.muted, isTrue);
    });

    test('11. Muted flag reduces effective volumes to 0 without losing configured levels', () {
      final unmuted = AudioSettings(
        masterVolume: 0.8,
        musicVolume: 0.5,
        sfxVolume: 0.7,
      );
      expect(unmuted.effectiveMusicVolume, closeTo(0.40, 0.001));
      expect(unmuted.effectiveSfxVolume, closeTo(0.56, 0.001));

      final muted = unmuted.copyWith(muted: true);
      // Effective volume is 0
      expect(muted.effectiveMusicVolume, equals(0.0));
      expect(muted.effectiveSfxVolume, equals(0.0));

      // Configured volume levels are preserved
      expect(muted.masterVolume, equals(0.8));
      expect(muted.musicVolume, equals(0.5));
      expect(muted.sfxVolume, equals(0.7));

      // Unmuting restores configured levels
      final restored = muted.copyWith(muted: false);
      expect(restored.effectiveMusicVolume, closeTo(0.40, 0.001));
      expect(restored.effectiveSfxVolume, closeTo(0.56, 0.001));
    });
  });
}
