# Hero asset contract

Each PNG contains exactly one isolated sprite on a transparent canvas. All frames belonging to the
same hero share one canvas size, horizontal center, and bottom baseline so switching frames does not
move the character unexpectedly.

## Naming

- Idle turnaround: `idle_<direction>.png`
- Animated state: `<state>_<direction>_<frame>.png`
- Directions use the sprite's on-screen orientation: `left`, `right`, `front`, `back`, and the four
  diagonal combinations.
- Frames use two-digit, one-based numbering such as `01` and `02`.
- Canonical left-facing idle and action frames are exact mirrors of their right-facing source frames.
- `source_idle_*` keeps the three non-canonical left-side poses from the supplied sheet. These are
  retained so no source frame is lost, but gameplay should use the canonical `idle_*` members.

## Current coverage

| Hero | Idle | Attack | Skill | Hurt |
| --- | --- | --- | --- | --- |
| `assassin` | 8 directions | 2 frames × left/right | — | — |
| `guardian` | 8 directions | 2 frames × left/right | — | — |
| `lotus_mage` | 8 directions | — | 2 frames × left/right | — |
| `monk` | 8 directions | 1 frame × left/right | 1 frame × left/right | — |
| `ranger` | 8 directions | 2 frames × left/right | — | — |
| `spear_guard` | 8 directions | 2 frames × left/right | — | — |
| `strategist` | 8 directions | — | 2 frames × left/right | — |
| `swordsman` | 8 directions | 1 frame × left/right | — | 1 frame × left/right |

The supplied sheets do not contain isolated `death`, `projectile`, enemy, or boss artwork. Do not
rename an unrelated pose to fill one of those states. Add those assets only from matching source art,
using the same isolation, canvas, baseline, naming, and left/right rules.
