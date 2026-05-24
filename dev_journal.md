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

## 2026-05-24 — Project cancelled

After two full art directions (painterly bakery → flat-vector isometric living room) and the full motion system (ambient choreographer + critters + bespoke prop reactions + hover feedback + reveal interactions + placement editor) shipped on the iso scene, the F5 result still did not match the user's reference bar (Lost and Found Co.).

Honest assessment of why:
- LFC has hand-painted scenes with hundreds of unique animated elements per scene.
- AI image gen produces consistent single static sprites but cannot reliably produce multi-frame character animation (drift between frames).
- The toolchain (Claude Code + Codex + Godot) caps at ~60-70% of LFC's perceived quality for a solo developer. The remaining 30-40% requires a human 2D animator — no AI shortcut exists for that today.
- User set LFC as the bar. The gap was honest and unbridgeable with this toolchain.

What we preserved (genuinely reusable for any future 2D Godot project):
- `scripts/`: scene_loader, game_manager, save_system, hint_system (reveal-aware),
  object_clickable, ambient_choreographer (7 behaviour types), critter (state-machine
  with hop/stretch/dart/drift), placement_editor (F2 drag-to-place w/ z_index + JSON
  save-back), gameplay.gd (full HOG loop)
- `scenes/`: main_menu, gameplay, scene_template, pause_menu, settings
- `data/scene_01.json` schema (hidden_objects + reveals + props)
- `assets_log.csv` with 80+ logged AI-art generations including the exact style-anchor
  workflow (Brief 1-6 patterns)
- `LFC_REFERENCE.md` with two-round research on LFC's actual mechanics + visual identity
- All Godot scaffolding, save system, hint system

What this repo can be used for next:
- Template for any 2D Godot project (the scaffold is solid)
- Reference for solo-dev + AI-art workflow constraints (what works, what doesn't)
- Pivot to a different genre that doesn't require character animation (sticker
  book, decoration game, idle/incremental cozy game)
- Stop here — the code + assets remain, no further work planned

## 2026-05-24 — Project pivot: bakery → isometric living room

User shared a reference screenshot of a Toca-Boca-style isometric cozy HOG with cutaway rooms + flat vector art. Painterly bakery direction abandoned.

Sequence:
1. Codex generated 8 v2 throwaways at `assets/_style_exploration_v2/iso_throwaway_01..08.png`
2. Reviewed all 8 — style is highly consistent (flat vector, isometric 3/4 cutaway, mint/peach/butter palette)
3. **Picked `iso_throwaway_05.png` (cozy living room)** as new locked style anchor

Why #05: 6+ usable HOG surfaces (sofa, coffee table, shelves, mantle, rug, armchair), warmest cozy vibe, full palette demonstration in one frame, natural NPC placements (sofa-reader, armchair-knitter, mantle-cat).

User constraints locked:
- No mascots (drop mc_idle bird from any future scene)
- Pivot tolerance: open-ended (acknowledged risk)
- Scene_01 is now a living room, not a bakery

Sunk cost: ~80% of bakery production art. All code (scaffold, autoloads, scene_loader, ambient_choreographer, critter, hint_system) survives the pivot 100%.

Next: hand Codex the Brief 5 (production art for iso living room scene_01) — see plan Addendum 11.
