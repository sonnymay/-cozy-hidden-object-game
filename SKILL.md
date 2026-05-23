# SKILL

> Skills the solo dev needs. Grouped by phase. Each entry has a "good enough" bar — chasing mastery is a Risk #8 (burnout) trigger.
>
> **Read `CLAUDE.md` first** — its four rules (Think → Simplicity → Surgical → Goal-Driven) override anything below if they conflict.

## Phase 1 — Prototype (NOW)

### Godot 4 / GDScript
**Why:** Engine. Everything else compiles down to this.
**Good enough:** Ship one scene end-to-end with autoloads, signals, Area2D click handling, ConfigFile save, JSON loading. The Phase 1 scaffold already exercises all of this.
**Resources:** Godot docs (godotengine.org/docs), "Dodge the Creeps" official tutorial (4 hrs), GDQuest free Godot 4 series.
**Triggers in master plan:** Section 4 (entire tech stack).

### Git
**Why:** Atomic commits per master plan Section 4f naming. Hard to ship 10 scenes without losing work otherwise.
**Good enough:** branch, commit, diff, revert, log. No remote until vertical slice.
**Triggers:** Section 4f.

### Free CC0 asset sourcing
**Why:** Phase 1 placeholders need to look passable.
**Good enough:** Find 8-10 CC0 icons on Kenney.nl or OpenGameArt; pull a chime + ambient loop off freesound.org; track license in `assets_log.csv`.
**Triggers:** Section 7 sprite spec (later) but Phase 1 uses CC0 stand-ins.

## Phase 2a — Style Lock + AI Art (NEXT)

### AI image prompting (Midjourney v7)
**Why:** Backbone of the visual pipeline. Section 0 calls this "the hardest part."
**Good enough:** Produce 5 backgrounds that look like one game using the Section 3e master style suffix, `--sref`, and `--cref`.
**Triggers:** Sections 3a-3f, 8 (every prompt template).

### Image cleanup — Photopea + rembg
**Why:** Raw AI output is not Steam-quality. Section 3b: "30-60 min cleanup per asset."
**Good enough:** Clean alpha cutouts (contract selection 1-2px to kill green halos), color correction to lock palette, paint over six-fingered hands.
**Triggers:** Sections 3b, 3g, 7 sprite spec, Risk #11.

### Asset logging discipline
**Why:** "You WILL need it at month 6." Section 3f.
**Good enough:** Every generation logged to `assets_log.csv` with prompt + seed + reference + filename.
**Triggers:** Section 3f.

## Phase 2b — Alive World (later)

### Godot 4 shaders (wind / flicker / vignette)
**Why:** Layer 1 ambient animation. The "alive" differentiator.
**Good enough:** Three working shaders, ≤10 lines each, copied from godotshaders.com and tuned.
**Triggers:** Section 4e.

### GPUParticles2D
**Why:** Dust motes, steam, sparkles, rain — Layer 1 ambient + found-item burst.
**Good enough:** ≤4 active emitters per scene; perf holds on integrated graphics (Risk #6).
**Triggers:** Section 5 Layer 1, Risk #6.

### Parallax layering
**Why:** The 5-PNG layered scene workflow. Section 3c.
**Good enough:** ParallaxBackground driven by Camera2D + cursor offset; 5-15 px max shift.
**Triggers:** Sections 3c, 4c, 4d.

### Tween easing
**Why:** Reveal interactions feel janky without it (Risk #5).
**Good enough:** Know `EASE_OUT_BACK` for snappy reveals; `EASE_IN_OUT` for ambient sways.
**Triggers:** Risk #5.

## Phase 2a/2b assist (when needed)

### ComfyUI + IP-Adapter (local)
**Why:** Max consistency control if Midjourney drift gets bad.
**Good enough:** Run a local SD pipeline, feed 5-10 reference images via IP-Adapter, get stable mascot output.
**Defer if:** Midjourney `--sref` + `--cref` are holding consistency. Don't learn unless you have to.
**Triggers:** Section 3b, 3f.

### Mascot LoRA training
**Why:** "Half-day learning, worth it for 10 scenes" (Section 3f).
**Good enough:** Trained LoRA that reproduces the locked mascot in any pose.
**Defer until:** mascot is locked AND Midjourney consistency is failing.
**Triggers:** Section 3f point 3.

### Krita
**Why:** Paint-over for AI artifacts beyond what Photopea handles.
**Defer if:** Photopea + selection contraction is enough.

## Phase 4-5 — Polish, Launch, Marketing

### DaVinci Resolve
**Why:** Trailer. The trailer is where alive-world execution converts to wishlists (Section 9).
**Good enough:** 45-60 sec trailer following Section 9 storyboard. Cuts on beat. Licensed cozy track.

### Steam Direct + GodotSteam
**Why:** Distribution + achievements + cloud saves.
**Good enough:** Steam Direct paid ($100), GodotSteam plugin wired for achievements + cloud saves + overlay. Demo published for Next Fest.
**Triggers:** Section 4d, 9.

### Audio sourcing
**Why:** "Bad/missing SFX screams amateur" — Section 9.
**Good enough:** 12 SFX (8 base + 4 prop reactions) + 3 BGM loops, all CC0 or licensed, license-tracked.
**Triggers:** Section 9 "How NOT to look cheap."

### Marketing — TikTok / Bluesky / Reddit
**Why:** "Marketing = 25% of total project time" (Risk #10).
**Good enough:** 5-sec alive-scene loops as the dominant content. 2-3 posts/week starting 4 months pre-launch. ≥50 likes/post by month 4 = signal market exists (Section 10 validation point #6).
**Triggers:** Section 9 marketing timeline, Risk #10.

## Skills I'm explicitly NOT learning yet

- Voice acting / dialogue trees (Section 1 "Avoid")
- 3D anything (Section 1 "Avoid")
- Custom shaders beyond wind/flicker/vignette (Section 10 "What NOT to waste time on")
- Localization (Section 1 "Avoid" at launch)
- Custom analytics (Section 10)
- Mascot animation beyond 5 static poses (Section 10)
- Mini-games, branching narrative (Section 1)

If a future session is tempted to invest time in any of these, push back — they violate `CLAUDE.md` rule 2 (Simplicity First).
