import 'dart:io';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Audio Cue & Asset Integrity Tests', () {
    test('1. Every BgmTrack resolves to an existing .ogg file in assets/audio', () {
      for (final track in BgmTrack.values) {
        final filePath = track.assetPath;
        final file = File(filePath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'BgmTrack.${track.name} points to non-existent file: $filePath',
        );
        expect(
          filePath.endsWith('.ogg'),
          isTrue,
          reason: 'BgmTrack.${track.name} must use .ogg format',
        );
      }
    });

    test('1. Every SfxCue resolves to an existing .ogg file in assets/audio', () {
      for (final cue in SfxCue.values) {
        final filePath = cue.assetPath;
        final file = File(filePath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'SfxCue.${cue.name} points to non-existent file: $filePath',
        );
        expect(
          filePath.endsWith('.ogg'),
          isTrue,
          reason: 'SfxCue.${cue.name} must use .ogg format',
        );
      }
    });

    test('2. No .wav files exist in Flutter runtime assets/audio', () {
      final assetsAudioDir = Directory('assets/audio');
      expect(assetsAudioDir.existsSync(), isTrue);

      final wavFiles = assetsAudioDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.wav'))
          .toList();

      expect(
        wavFiles,
        isEmpty,
        reason: 'Master WAV files must not be included in Flutter runtime bundle: $wavFiles',
      );
    });

    test('Master WAV files exist in audio_source/master for archive', () {
      final masterDir = Directory('audio_source/master');
      expect(masterDir.existsSync(), isTrue);

      final wavCount = masterDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.wav'))
          .length;

      expect(wavCount, equals(23));
    });
  });
}
