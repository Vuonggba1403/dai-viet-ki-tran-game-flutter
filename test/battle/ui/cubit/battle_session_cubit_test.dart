import 'package:bloc_test/bloc_test.dart';
import 'package:ezwork/battle/data/data_sources/local_battle_content_data_source.dart';
import 'package:ezwork/battle/data/repositories/battle_content_repository.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_cubit.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_effect.dart';
import 'package:ezwork/battle/ui/cubit/battle_session_state.dart';
import 'package:flutter_test/flutter_test.dart' hide MatchFinder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BattleSessionCubit', () {
    late BattleContentRepository repository;

    setUp(() {
      repository = BattleContentRepository(
        localDataSource: const LocalBattleContentDataSource(),
      );
    });

    test('initial state is BattleSessionState.initial()', () {
      final cubit = BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 123,
      );
      expect(cubit.state, equals(const BattleSessionState.initial()));
    });

    blocTest<BattleSessionCubit, BattleSessionState>(
      'loadStage emits [loading, ready] on successful load',
      build: () => BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      ),
      act: (cubit) => cubit.loadStage(),
      expect: () => [
        const BattleSessionState.loading(),
        isA<BattleSessionStateReady>()
            .having((s) => s.currentStage.id, 'stageId', 'stage_1')
            .having((s) => s.comboCount, 'comboCount', 0)
            .having((s) => s.isPaused, 'isPaused', isFalse),
      ],
    );

    blocTest<BattleSessionCubit, BattleSessionState>(
      'pause and resume update isPaused flag',
      build: () => BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      ),
      act: (cubit) async {
        await cubit.loadStage();
        cubit
          ..pause()
          ..resume();
      },
      skip: 2, // skip loading and initial ready
      expect: () => [
        isA<BattleSessionStateReady>().having(
          (s) => s.isPaused,
          'isPaused',
          isTrue,
        ),
        isA<BattleSessionStateReady>().having(
          (s) => s.isPaused,
          'isPaused',
          isFalse,
        ),
      ],
    );

    blocTest<BattleSessionCubit, BattleSessionState>(
      'updateCombo sets comboCount directly per resolution',
      build: () => BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      ),
      act: (cubit) async {
        await cubit.loadStage();
        cubit
          ..updateCombo(3)
          ..updateCombo(1);
      },
      skip: 2,
      expect: () => [
        isA<BattleSessionStateReady>().having(
          (s) => s.comboCount,
          'comboCount',
          3,
        ),
        isA<BattleSessionStateReady>().having(
          (s) => s.comboCount,
          'comboCount',
          1,
        ),
      ],
    );

    blocTest<BattleSessionCubit, BattleSessionState>(
      'loadStage with unknown stageId emits [loading, error] and showError effect',
      build: () => BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      ),
      act: (cubit) => cubit.loadStage(stageId: 'non_existent_stage'),
      expect: () => [
        const BattleSessionState.loading(),
        isA<BattleSessionStateError>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Màn chơi không tồn tại. Vui lòng chọn lại màn chơi.',
        ),
      ],
      verify: (cubit) {
        expect(cubit.state, isA<BattleSessionStateError>());
      },
    );

    blocTest<BattleSessionCubit, BattleSessionState>(
      'retryBattle preserves stageId from previous load',
      build: () => BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      ),
      act: (cubit) async {
        await cubit.loadStage(stageId: 'stage_2');
        await cubit.retryBattle();
      },
      skip: 2, // skip initial loading and stage_2 ready
      expect: () => [
        const BattleSessionState.loading(),
        isA<BattleSessionStateReady>().having(
          (s) => s.currentStage.id,
          'stageId',
          'stage_2',
        ),
      ],
    );

    test('exitBattle emits BattleSessionEffect.exitToHome()', () async {
      final cubit = BattleSessionCubit(
        contentRepository: repository,
        initialSeed: 42,
      );

      final effects = <BattleSessionEffect>[];
      cubit.effectsStream.listen(effects.add);

      cubit.exitBattle();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(effects, equals([const BattleSessionEffect.exitToHome()]));
    });
  });
}
