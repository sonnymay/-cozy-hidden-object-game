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

## Backlog (Phase 2 prep)

- Generate 5 throwaway scene backgrounds to lock visual style.
- Pick mascot silhouette (bird / bunny / cat).
- Train mascot LoRA once style is locked.
