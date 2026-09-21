# Game asset contract

This structure follows the gameplay taxonomy in the
[Game Design Document](https://app.notion.com/p/3e2121177a6180d08a48c8e91f7ae237),
[Gameplay & Combat System](https://app.notion.com/p/3e2121177a618197ae5ac4989f8fa6ed), and
[Flutter + Flame Execution Plan](https://app.notion.com/p/3e2121177a6181968d39c0177338b6ae).

## Runtime rules

- Every PNG contains one isolated asset only. Transparent assets have a safety margin and no pixels
  from neighboring source-sheet cells.
- Filenames and folders use semantic lowercase `snake_case`.
- Access runtime files through `Assets.images.game`; do not add raw path constants.
- Enemy frames in one folder share a common canvas and bottom baseline. Left-facing action frames are
  exact mirrors of their right-facing source frames.
- VFX and UI assets keep tight transparent canvases because Flame owns their position, scale, lifetime,
  animation queue, and pooling. They must not become domain state or Cubit per-frame state.
- Backgrounds are opaque battle plates with the source divider removed.

## Match-3 alignment

The current prototype uses `sword`, `fire`, `water`, `lightning`, and `heart`. `shield` artwork is
included for the later ruleset but remains deferred according to the execution plan; shield can still
be created by a skill.

Special tiles map to the board rules:

- `line_horizontal` and `line_vertical`: match 4 row/column clear;
- `bomb`: T/L area clear;
- `power_gem`: match 5 type clear;
- `power_sword` and `power_shadow`: reserved source variants, not active MVP rules.

Tile overlays are visual states only: selected, locked, frozen, poisoned, stunned, and cracked. The
domain tile remains the source of truth for type, special type, lock/debuff, and board position.

## Current coverage

| Area | Folder | Assets |
| --- | --- | ---: |
| Match-3 tiles and ready states | `tiles/base/` | 12 |
| Special tiles | `tiles/special/` | 6 |
| Tile state overlays | `tiles/overlays/` | 6 |
| Projectiles | `vfx/projectiles/` | 3 |
| Combat impact/slash VFX | `vfx/combat/` | 13 |
| Elemental VFX | `vfx/elemental/` | 6 |
| Heal/shield/buff/debuff VFX | `vfx/status/` | 9 |
| Enemy frames | `enemies/` | 16 |
| Battle backgrounds | `backgrounds/battle/` | 4 |
| Battle HUD and result controls | `ui/battle/` | 18 |
| Currency/consumables/equipment/materials | `items/` | 18 |
| Chest and stage star | `rewards/` | 2 |

No supplied sheet contains a distinct boss, props/foreground, Home UI, World Map, stage node,
Hero/Inventory UI, Quest/Shop UI, loading/splash, SFX, or BGM asset. Add those only when matching
source files exist; do not repurpose unrelated art.

## Remaining rollout order

Continue with real source art in this order:

1. boss;
2. props and foreground layers;
3. Home UI;
4. World Map and stage nodes;
5. Hero and Inventory UI;
6. Quest and Shop UI;
7. loading and splash;
8. `assets/audio/sfx/`;
9. `assets/audio/bgm/`.

Declare only populated leaf directories in `pubspec.yaml`, then regenerate flutter_gen after every
add, rename, or delete.
