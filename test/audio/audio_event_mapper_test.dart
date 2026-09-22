import 'package:dai_viet_ki_tran_game/audio/domain/audio_cue.dart';
import 'package:dai_viet_ki_tran_game/audio/domain/audio_event_mapper.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_event.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/board_position.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/board/swap.dart';
import 'package:dai_viet_ki_tran_game/battle/domain/combat/combat_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioEventMapper Tests', () {
    const mapper = AudioEventMapper();
    const swap = Swap(from: BoardPosition(0, 0), to: BoardPosition(0, 1));

    test('3. BoardEvent swap events map to tileSwap', () {
      expect(mapper.mapBoardEvent(const SwapStarted(swap)), equals(SfxCue.tileSwap));
      expect(mapper.mapBoardEvent(const SwapRejected(swap)), equals(SfxCue.tileSwap));
    });

    test('3. BoardEvent TilesMatched cycle 1 maps to match_3', () {
      final event = TilesMatched(cycle: 1, matches: const []);
      expect(mapper.mapBoardEvent(event), equals(SfxCue.match3));
    });

    test('3. BoardEvent TilesMatched cycles 2, 3, 4 map to respective combos', () {
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 2, matches: const [])),
        equals(SfxCue.combo2),
      );
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 3, matches: const [])),
        equals(SfxCue.combo3),
      );
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 4, matches: const [])),
        equals(SfxCue.combo4),
      );
    });

    test('4. Cascade cycle >= 5 always maps to combo_max', () {
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 5, matches: const [])),
        equals(SfxCue.comboMax),
      );
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 6, matches: const [])),
        equals(SfxCue.comboMax),
      );
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 10, matches: const [])),
        equals(SfxCue.comboMax),
      );
      expect(
        mapper.mapBoardEvent(TilesMatched(cycle: 99, matches: const [])),
        equals(SfxCue.comboMax),
      );
    });

    test('Cycle > 1 does not return match_3', () {
      for (var cycle = 2; cycle <= 10; cycle++) {
        final cue = mapper.mapBoardEvent(TilesMatched(cycle: cycle, matches: const []));
        expect(cue, isNot(equals(SfxCue.match3)));
      }
    });

    test('Non-sound board events return null', () {
      expect(mapper.mapBoardEvent(const CascadeStarted(1)), isNull);
      expect(mapper.mapBoardEvent(const CascadeCompleted(1)), isNull);
      expect(mapper.mapBoardEvent(TilesCleared(cycle: 1, positions: const [])), isNull);
      expect(mapper.mapBoardEvent(TilesDropped(cycle: 1, drops: const [])), isNull);
      expect(mapper.mapBoardEvent(TilesSpawned(cycle: 1, spawns: const [])), isNull);
    });

    test('Combat skills map to respective spell and attack sounds', () {
      expect(
        mapper.mapCombatEvent(
          const CombatSkillExecuted(
            heroId: 'h1',
            skillId: 'skill_hoa_long_quyet',
            manaSpent: 40,
          ),
        ),
        equals(SfxCue.fireCast),
      );
      expect(
        mapper.mapCombatEvent(
          const CombatSkillExecuted(
            heroId: 'h2',
            skillId: 'skill_tram_long_kich',
            manaSpent: 40,
          ),
        ),
        equals(SfxCue.swordSlash),
      );
      expect(
        mapper.mapCombatEvent(
          const CombatSkillExecuted(
            heroId: 'h3',
            skillId: 'skill_loi_dinh_chuong',
            manaSpent: 40,
          ),
        ),
        equals(SfxCue.lightning),
      );
      expect(
        mapper.mapCombatEvent(
          const CombatSkillExecuted(
            heroId: 'h4',
            skillId: 'skill_thuy_tran_thu',
            manaSpent: 40,
          ),
        ),
        equals(SfxCue.heal),
      );
    });

    test('5. Multi-target heal skill emits heal cue once for the skill execution', () {
      // Skill execution event maps to single heal cue
      const skillEvent = CombatSkillExecuted(
        heroId: 'h4',
        skillId: 'skill_thuy_tran_thu',
        manaSpent: 40,
      );
      expect(mapper.mapCombatEvent(skillEvent), equals(SfxCue.heal));

      // Individual CombatHeroHealed events return null so they do not duplicate
      const heroHeal1 = CombatHeroHealed(heroId: 'h1', amount: 300, currentHp: 800);
      const heroHeal2 = CombatHeroHealed(heroId: 'h2', amount: 300, currentHp: 900);
      const heroHeal3 = CombatHeroHealed(heroId: 'h3', amount: 300, currentHp: 750);
      const heroHeal4 = CombatHeroHealed(heroId: 'h4', amount: 300, currentHp: 1000);

      expect(mapper.mapCombatEvent(heroHeal1), isNull);
      expect(mapper.mapCombatEvent(heroHeal2), isNull);
      expect(mapper.mapCombatEvent(heroHeal3), isNull);
      expect(mapper.mapCombatEvent(heroHeal4), isNull);
    });

    test('6. Normal damage emits enemyHit and critical damage emits criticalHit exclusively', () {
      const normalDmg = CombatEnemyDamaged(
        enemyId: 'e1',
        damage: 150,
        remainingHp: 850,
        isCriticalOrEffective: false,
      );
      expect(mapper.mapCombatEvent(normalDmg), equals(SfxCue.enemyHit));

      const critDmg = CombatEnemyDamaged(
        enemyId: 'e1',
        damage: 400,
        remainingHp: 450,
        isCriticalOrEffective: true,
      );
      expect(mapper.mapCombatEvent(critDmg), equals(SfxCue.criticalHit));
      expect(mapper.mapCombatEvent(critDmg), isNot(equals(SfxCue.enemyHit)));
    });

    test('Combat victory and defeat map correctly', () {
      expect(
        mapper.mapCombatEvent(const CombatVictorious(finalScore: 12000)),
        equals(SfxCue.victory),
      );
      expect(
        mapper.mapCombatEvent(const CombatDefeated(reason: 'All heroes fallen')),
        equals(SfxCue.defeat),
      );
    });
  });
}
