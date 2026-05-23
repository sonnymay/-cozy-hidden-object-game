# Cozy HOG Prototype

Phase 1 scaffold for a cozy hidden-object game. See `cozy_hidden_object_game_master_plan (1).md` (one folder up) for the full design.

## Run

1. Install **Godot 4.3+** from <https://godotengine.org/download>.
2. Open this folder in the Godot project manager (Import → pick `project.godot`).
3. Press F5 — Main Menu loads. Click Play.
4. Click the colored rectangles where the hidden objects live (positions are in `data/scene_01.json`). Each click strikes the item off the list and plays a sparkle.

> The first launch will regenerate `.godot/` and import asset metadata. That's normal.

## Status

- Core loop: clickable hidden objects, object list, found chime, sparkle particle, completion panel
- Hint system: 60s cooldown, 3 hints/scene, pulse highlight on a random unfound object
- Save system: `user://save.cfg` with `.bak` rotation; per-scene completion + hint count
- Settings: volume + fullscreen only
- JSON-driven scene data — tune levels without recompiling

## Not yet (Phase 2)

- Layered parallax backgrounds, wind/flicker shaders, ambient particles
- Interactive delight props, reveal interactions
- AI-generated art, mascot
- Steam integration

## Layout

```
assets/      placeholder art + future AI assets
data/        scene_NN.json definitions
scenes/      .tscn files
scripts/     .gd files (autoloads: GameManager, SaveSystem)
exports/     build outputs (gitignored)
```

## Placeholder art

The current `data/scene_01.json` references a background and sprites that don't exist yet — `scene_loader.gd` falls back to colored rectangles so the loop is playable immediately. Drop real PNGs into `assets/backgrounds/scene_01/` and `assets/objects/scene_01/` to replace them.

## Validation gate (week 4)

Show to 3 strangers. Pass = all 3 finish unaided AND ≥1 asks for more levels. Fail = fix the loop before any AI-art work begins.
