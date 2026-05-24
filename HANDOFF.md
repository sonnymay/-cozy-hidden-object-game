# HANDOFF

> **Read me first, then in order:** `../cozy_hidden_object_game_master_plan (1).md` → `CLAUDE.md` → `SKILL.md` → this file.

## Project

Cozy hidden-object game in Godot 4. Differentiator: scenes that *breathe, twinkle, and react to touch* (parallax + ambient particles + interactive props + reveal interactions). Solo dev, 12-15 months part-time, target $7.99 on Steam.

## Current state — last updated 2026-05-24 (Brief 5 art wired)

**Scene_01 is now a cozy living room in flat-vector isometric style.** Brief 5 production art (35 PNGs) landed and is wired into Godot. Bakery scaffolding removed (parallax, wind shader, mascot, old prop IDs). `godot --headless --quit-after 180 res://scenes/gameplay.tscn` boots zero errors.

What's wired:
- `bg_living_room.png` as a single Sprite2D background (no parallax — flat iso)
- 15 hidden objects positioned naturally across sofa / coffee table / mantle / shelves / floor (4 of them gated inside 3 reveals)
- 10 living-room props with hover + bespoke reactions: mantle_clock, floor_lamp, throw_pillow, fireplace, vase, plant, tea_on_table, blanket, book_stack, picture_frame
- 3 reveals (sofa cushion lift, coffee drawer, mantle box) with sprite-swap animations
- 3 static NPC Sprite2Ds: npc_reader on sofa, npc_knitter in armchair, npc_cat on rug (no click handlers — they don't intercept hidden-object clicks)
- 2 ambient critters: bird (windowsill hop) + butterfly (drift). Animal critters (cat, mouse) removed — npc_cat covers the cat role.
- Ambient choreographer driving idle animation on all 10 props
- Lantern PointLight2D in fireplace area for warm glow
- Dust motes in upper-left sun area
- Sparkle particles on found-item
- Hint system reveal-aware
- Placement editor (F2) ready for fine-tuning
- HUD + completion + Esc all preserved

What's gone:
- ParallaxBackground + 5 layers
- Wind shader on overlay
- Mascot Sprite2D (no mascots per user spec)
- Bakery prop IDs in PROP_AMBIENTS (legacy entries kept in _dispatch_reaction match for backward compat)

----

## Earlier state — 2026-05-23 (Brief 4 / bakery)

**Scene_01 wired with Codex production art.** Godot 4.6.3 stable. `godot --headless --quit-after 120 res://scenes/gameplay.tscn` boots the gameplay scene cleanly with zero errors after a `--import` pass.

Production art delivered by Codex (Brief 4 in plan addendum 6):
- 5 background parallax layers in `assets/backgrounds/scene_01/` (`bg_01_sky` → `bg_05_overlay`)
- 15 hidden-object sprites in `assets/objects/scene_01/` (8 original + 7 new — thimble, mouse, pinecone, snail, ribbon, postcard, button)
- 11 prop sprites in `assets/props/scene_01/` (mixer, awning, curtain, flower_pot, lantern, plant, kettle, bell, drawer_closed/open, picture_frame)
- 6 reveal-state sprites in `assets/reveals/scene_01/` (wardrobe/rug/teapot, each closed + open)
- 1 mascot at `assets/characters/mc_idle.png`
- All 38 generations logged in `assets_log.csv`

Godot scene wiring (this turn):
- `scenes/gameplay.tscn`: replaced single `Background` Sprite2D with `ParallaxBackground` + 5 `ParallaxLayer` children (motion_scale 0.1/0.3/0.6/0.85/1.0)
- `scripts/gameplay.gd`: cursor parallax via `parallax.scroll_offset` lerp in `_process`; legacy `data.background` JSON key ignored now that bg is authored in the .tscn
- Mascot Sprite2D added to gameplay scene, bottom-right corner, scaled 0.55
- `data/scene_01.json` (already at 15 objects + 3 reveal/prop entries from prior turn) — Godot loader currently consumes only `hidden_objects`; reveals + props remain HTML-preview-only

Audit fixes from earlier (still in place):
- `ui_cancel` action for back-to-menu (Esc)
- Visible `Polygon2D` hint-pulse circle
- Completion panel Continue button

What's stubbed / falls back:
- Chime SFX silent until `assets/audio/sfx/chime.wav` lands (Step 2 audio sourcing)
- Reveals + interactive props not yet wired in Godot — work in the HTML preview only
- No BGM yet

## Decisions locked

- **OS target:** macOS only for now (Windows later)
- **Git:** remote at https://github.com/sonnymay/-cozy-hidden-object-game (added 2026-05-24, overriding earlier local-only decision). Push to `origin main` on every commit going forward.
- **Renderer:** GL Compatibility (low-spec friendly)
- **Save format:** `ConfigFile` at `user://save.cfg` with `.bak` rotation
- **Scene data:** JSON in `data/`, hot-tunable without recompile
- **Autoloads:** `GameManager` (loop state), `SaveSystem` (persistence)
- **Locked style reference (v2 — current):** `assets/_style_exploration_v2/iso_throwaway_05.png` (cozy living room, isometric 3/4 cutaway, flat vector cartoon, mint/peach/butter/dusty-rose palette). All future generations must use this image as `--sref` (Midjourney) or IP-Adapter input (SDXL/ComfyUI).
- **Abandoned style reference (v1):** `assets/_style_exploration/bg_throwaway_01.png` (painterly bakery). Project pivoted to flat-vector isometric on 2026-05-24 — see Addendum 9 in plan. Bakery production art (5 bg layers, 11 props, 6 reveals, mc_idle) is sunk cost; do not use it for new scenes.
- **Scene_01 setting (post-pivot):** cozy living room (not bakery). 15 hidden objects + props + reveals to be regenerated by Codex in the new locked style.
- **No mascots** — user spec, 2026-05-24. Drop mc_idle bird from scenes; don't generate replacement mascots.

## Next action (resume here)

**User: F5 the new living-room scene and judge.** Confirm:
1. `bg_living_room.png` fills the viewport correctly.
2. 15 hidden objects visible in plausible positions on living-room surfaces (some may need F2-placement-editor tuning — that's fine).
3. 11 of the 15 are immediately clickable; 4 are hidden behind reveals (Teacup + Letter in coffee drawer, Brass Key + Sock under sofa cushion, Thimble in mantle box).
4. Clicking each prop triggers its bespoke reaction (hover brightens + reaction tween).
5. Hint button works + 60s cooldown + reveal-aware pulses.
6. Completion modal appears after all 15 found.
7. Esc returns to main menu.
8. NO mascot bird visible.
9. NPC reader / knitter / cat visible but don't intercept clicks meant for hidden objects.

**If a hidden object or prop sits in a dumb spot:** press F2 to enter placement mode, drag the item to a better surface, Z to cycle z_index, S to save. No code or art changes needed — JSON updates in place.

**After F5 review passes:**
- Hand Brief 6 to Codex (50-sprite shared library, drafted in plan addendum 12)
- Once library lands, dense-populate the living room via placement editor for the "hundreds of elements" LFC feel
- Decide on alive mechanics A-E (cursor-reactive, env events, celebration chains, camera breathing, critter migrations)

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
