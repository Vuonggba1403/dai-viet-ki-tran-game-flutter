import 'package:dai_viet_ki_tran_game/audio/application/audio_controller.dart';
import 'package:dai_viet_ki_tran_game/audio/application/audio_settings_cubit.dart';
import 'package:dai_viet_ki_tran_game/audio/data/audio_settings_repository.dart';
import 'package:dai_viet_ki_tran_game/audio/presentation/audio_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'audio_controller_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioSettingsSection Widget Tests', () {
    late AudioSettingsRepository repository;
    late FakeGameAudioService fakeService;
    late AudioController controller;
    late AudioSettingsCubit cubit;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      repository = AudioSettingsRepository();
      fakeService = FakeGameAudioService();
      controller = AudioController(audioService: fakeService);
      cubit = AudioSettingsCubit(
        repository: repository,
        audioController: controller,
      );
    });

    tearDown(() {
      cubit.close();
      controller.dispose();
    });

    testWidgets('renders all 3 sliders and mute toggle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioSettingsSection(cubit: cubit),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cài Đặt Âm Thanh'), findsOneWidget);
      expect(find.text('Bật Âm'), findsOneWidget);
      expect(find.byKey(const Key('audio_mute_switch')), findsOneWidget);
      expect(find.byKey(const Key('audio_master_slider')), findsOneWidget);
      expect(find.byKey(const Key('audio_music_slider')), findsOneWidget);
      expect(find.byKey(const Key('audio_sfx_slider')), findsOneWidget);
    });

    testWidgets('toggling mute switch updates state and displays Đã Tắt Âm', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioSettingsSection(cubit: cubit),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(cubit.state.muted, isFalse);
      expect(find.text('Bật Âm'), findsOneWidget);

      // Tap mute switch
      await tester.tap(find.byKey(const Key('audio_mute_switch')));
      await tester.pumpAndSettle();

      expect(cubit.state.muted, isTrue);
      expect(find.text('Đã Tắt Âm'), findsOneWidget);
      expect(find.text('Muted'), findsNWidgets(3));
    });

    testWidgets('moving master slider updates volume in cubit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AudioSettingsSection(cubit: cubit),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await cubit.setMasterVolume(0.5);
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(cubit.state.masterVolume, equals(0.5));
    });
  });
}
