# Dev Journal

## 2026-05-23 — Phase 1 scaffold

- Initialized Godot 4 project structure per master plan Section 4b.
- Autoloads: `GameManager`, `SaveSystem`.
- Placeholder art only. No AI generation until prototype validates the loop.
- Next: open in Godot 4.3+, verify `main_menu.tscn` launches, click through to `gameplay.tscn`.

## Decisions

- **Renderer:** GL Compatibility (low-spec laptops in target audience).
- **Resolution:** 1920×1080 base, canvas_items stretch, keep aspect.
- **Save path:** `user://save.cfg` with `.bak` rotation.
- **Scene data format:** JSON in `data/` — no recompile to tune levels.

## 2026-05-23 — Style locked

Reviewed 10 Codex-generated throwaways at `assets/_style_exploration/bg_throwaway_01.png` through `_10.png`. Locked **`bg_throwaway_01.png` (cozy bakery interior at golden hour)** as the canonical style reference.

Why this one:
- Palette nails cream/peach/sage/dusty rose cleaner than any of the others (#08 close second).
- Big empty wooden island + sage counter = best HOG composition canvas; satisfies "empty surfaces ready for items" rule.
- Upper-left window light is dramatic and easy to reproduce.
- Matches master plan Section 2's literal MVP example ("Magical Bakery").
- No JSON edits needed — `data/scene_01.json` already targets a bakery.

Rejected the busy-shelf options (02 bookshop, 04 post office, 07 clockmaker, 09 apothecary) because their pre-baked items would compete visually with hidden-object sprites and break the fairness rule from master plan Section 5.

## Backlog (Phase 2 prep)

- ~~Generate 10 throwaway scene backgrounds to lock visual style.~~ ✓ done
- ~~Pick locked style reference.~~ ✓ `bg_throwaway_01.png`
- Run Brief 3 in Codex with `bg_throwaway_01.png` as `--sref` to overwrite the Pillow placeholders.
- Pick mascot silhouette (bird / bunny / cat).
- Train mascot LoRA once style is locked.
