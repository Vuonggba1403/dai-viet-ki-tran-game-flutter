import 'package:dai_viet_ki_tran_game/audio/application/audio_controller.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_settings.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/game_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGameAudioService implements GameAudioService {
  BgmTrack? activeTrack;
  int playBgmCallCount = 0;
  int stopBgmCallCount = 0;
  int pauseBgmCallCount = 0;
  int resumeBgmCallCount = 0;
  bool isUnlocked = false;
  AudioSettings settings = AudioSettings();
  final List<SfxCue> playedSfx = [];

  bool throwOnPlay = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> unlock() async {
    isUnlocked = true;
  }

  @override
  Future<void> playBgm(BgmTrack track, {Duration? fade}) async {
    if (throwOnPlay) {
      throw Exception('Simulated audio engine error');
    }
    playBgmCallCount++;
    activeTrack = track;
  }

  @override
  Future<void> stopBgm({Duration? fade}) async {
    stopBgmCallCount++;
    activeTrack = null;
  }

  @override
  Future<void> pauseBgm() async {
    pauseBgmCallCount++;
  }

  @override
  Future<void> resumeBgm() async {
    resumeBgmCallCount++;
  }

  @override
  Future<void> playSfx(SfxCue cue, {double volume = 1.0}) async {
    if (throwOnPlay) {
      throw Exception('Simulated SFX engine error');
    }
    playedSfx.add(cue);
  }

  @override
  Future<void> updateSettings(AudioSettings newSettings) async {
    settings = newSettings;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioController & BGM Lifecycle Tests', () {
    late FakeGameAudioService fakeService;
    late AudioController controller;

    setUp(() {
      fakeService = FakeGameAudioService();
      controller = AudioController(audioService: fakeService);
    });

    tearDown(() {
      controller.dispose();
    });

    test('7. Calling enterHome multiple times is idempotent and does not restart track', () async {
      await controller.enterHome();
      expect(fakeService.activeTrack, equals(BgmTrack.home));
      expect(fakeService.playBgmCallCount, equals(1));

      // Second call while already at home
      await controller.enterHome();
      expect(fakeService.playBgmCallCount, equals(1)); // Did NOT restart!

      // Third call
      await controller.enterHome();
      expect(fakeService.playBgmCallCount, equals(1));
    });

    test('8. BGM route transition correctly switches between Home, Battle, and Boss', () async {
      // 1. Enter Home
      await controller.enterHome();
      expect(fakeService.activeTrack, equals(BgmTrack.home));
      expect(fakeService.playBgmCallCount, equals(1));

      // 2. Transition to regular battle
      await controller.enterBattle(isBoss: false);
      expect(fakeService.activeTrack, equals(BgmTrack.battle));
      expect(fakeService.playBgmCallCount, equals(2));

      // Calling regular battle again does not restart
      await controller.enterBattle(isBoss: false);
      expect(fakeService.playBgmCallCount, equals(2));

      // 3. Transition to boss battle
      await controller.enterBattle(isBoss: true);
      expect(fakeService.activeTrack, equals(BgmTrack.boss));
      expect(fakeService.playBgmCallCount, equals(3));

      // 4. Return to Home
      await controller.enterHome();
      expect(fakeService.activeTrack, equals(BgmTrack.home));
      expect(fakeService.playBgmCallCount, equals(4));
    });

    test('Battle pause ducks/pauses and resume restores BGM', () async {
      await controller.enterBattle(isBoss: false);
      expect(controller.isPausedByGame, isFalse);

      await controller.pauseBattle();
      expect(controller.isPausedByGame, isTrue);
      expect(fakeService.pauseBgmCallCount, equals(1));

      await controller.resumeBattle();
      expect(controller.isPausedByGame, isFalse);
      expect(fakeService.resumeBgmCallCount, equals(1));
    });

    test('Victory and Defeat fanfare play exactly once', () async {
      await controller.enterBattle(isBoss: false);

      // Trigger victory multiple times (simulating cubit re-emits / rebuilds)
      await controller.handleVictory();
      await controller.handleVictory();
      await controller.handleVictory();

      final victoryCues = fakeService.playedSfx
          .where((c) => c == SfxCue.victory)
          .length;
      expect(victoryCues, equals(1));

      // Reset for defeat test
      await controller.enterBattle(isBoss: true);
      await controller.handleDefeat();
      await controller.handleDefeat();

      final defeatCues = fakeService.playedSfx
          .where((c) => c == SfxCue.defeat)
          .length;
      expect(defeatCues, equals(1));
    });

    test('12. Audio failure does not crash or bubble uncaught exceptions', () async {
      fakeService.throwOnPlay = true;

      // None of these should throw
      await expectLater(controller.enterHome(), completes);
      await expectLater(controller.playSfx(SfxCue.buttonClick), completes);
      await expectLater(controller.handleVictory(), completes);
    });
  });
}
