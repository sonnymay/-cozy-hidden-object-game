# HANDOFF

> **Read me first, then in order:** `../cozy_hidden_object_game_master_plan (1).md` → `CLAUDE.md` → `SKILL.md` → this file.

## Project

Cozy hidden-object game in Godot 4. Differentiator: scenes that *breathe, twinkle, and react to touch* (parallax + ambient particles + interactive props + reveal interactions). Solo dev, 12-15 months part-time, target $7.99 on Steam.

## Current state — last updated 2026-05-23

**Phase 1 scaffold complete, unverified.** Files on disk; initial git commit at `9b30e41`. Godot is not installed locally so the prototype has never actually launched.

Scaffold audit completed before commit — known fragile spots already addressed:
- Removed hand-written `InputEventKey` Object syntax from `project.godot`; gameplay now uses Godot's built-in `ui_cancel` action (Esc) for back-to-menu.
- `HintPulse` was an empty `Sprite2D` (invisible); replaced with a 16-vertex `Polygon2D` circle so the hint highlight is actually visible.
- `CompletionPanel` had no dismiss UI; added Continue button → returns to main menu.
- Placeholder PNGs generated via Pillow (1920×1080 pastel background + 8 × 128px sprites) so the scaffold renders real art instead of ColorRect fallbacks.

What exists:
- `project.godot` — Godot 4.3, GL Compatibility, 1920×1080, autoloads `GameManager` + `SaveSystem`
- `scenes/`: `main_menu.tscn`, `gameplay.tscn`, `scene_template.tscn`, `pause_menu.tscn`, `settings.tscn`
- `scripts/`: `game_manager.gd`, `save_system.gd`, `object_clickable.gd`, `hint_system.gd`, `scene_loader.gd`, `gameplay.gd`, `main_menu.gd`, `settings.gd`
- `data/scene_01.json` — 8 placeholder hidden objects (JSON-validated)
- `assets/` folder tree with `scene_01` subfolders; no real art or audio yet
- `assets_log.csv`, `dev_journal.md`, `README.md`, `.gitignore`, git initialized

What's stubbed / falls back gracefully:
- Background sprite — `scene_loader.gd` uses ColorRect rectangles when sprite/background PNGs missing
- Chime SFX — silent until a `.wav` is dropped at `assets/audio/sfx/chime.wav`
- Sparkle particles — yellow GPUParticles2D defined inline in `gameplay.tscn`

## Decisions locked

- **OS target:** macOS only for now (Windows later)
- **Git:** local-only, no remote until vertical slice
- **Renderer:** GL Compatibility (low-spec friendly)
- **Save format:** `ConfigFile` at `user://save.cfg` with `.bak` rotation
- **Scene data:** JSON in `data/`, hot-tunable without recompile
- **Autoloads:** `GameManager` (loop state), `SaveSystem` (persistence)
- **No AI art until Phase 1 validates** — placeholder rectangles only

## Next action (resume here)

**Step D from the addendum plan: smoke test the scaffold.**
1. Install Godot 4.3+ from <https://godotengine.org/download> (macOS Universal binary).
2. Open `project.godot` via Godot project manager.
3. Press F5 → Main Menu loads → Play.
4. Confirm: 8 peach rectangles visible → click each → strikethrough on list + sparkle particle → completion panel shows correct counts.
5. Confirm: Hint button consumes 1 of 3 hints, pulses a random unfound rect, then locks for 60s.
6. Quit, relaunch → main menu loads (save state for completion will only appear after one full clear).
7. Press Esc during gameplay → returns to main menu.

Any error → fix in scaffold code, not new features. Likely suspects: hand-written `.tscn` UIDs, autoload paths, `ParticleProcessMaterial` defaults.

## After smoke test passes

**Step E — Phase 2a Week 1 style lock** (per master plan "This Week's Actions"):
1. Subscribe to Midjourney commercial tier.
2. Generate 10 throwaway scene backgrounds using the Section 3e style suffix verbatim.
3. Stack 5 layers for one scene; verify they look like one coherent image.
4. Pick the locked style; archive 5-10 "golden" reference images.
5. Log every prompt + seed in `assets_log.csv`.

Open a fresh plan for Phase 2a — don't bolt onto this one.

## Open questions

1. Confirm Godot 4.3+ install before next session, or include install steps when we execute?
2. Windows export from day one or stay macOS-only until vertical slice?
3. Push to GitHub now (good for backups + TikTok dev-log clips) or stay local?

## Validation gate (Phase 1 exit)

3 strangers play the prototype. Pass = all 3 finish unaided AND ≥1 asks "more levels?". Fail = revisit the loop before any AI art work begins.

## Risk watch (from master plan Section 10)

- #1 art consistency — not relevant until Phase 2a starts
- #2 layered scene composition time — track Phase 2b hours carefully; if first alive scene takes 140 hrs, cut from 10 scenes to 7
- #3 scope creep — feature freeze at end of Phase 2b; new ideas → `dlc_ideas.md` (not yet created)
- #8 burnout — ship vertical slice publicly for external accountability
