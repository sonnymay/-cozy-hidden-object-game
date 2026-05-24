# Lost and Found Co. — Reference Doc

Canonical understanding of LFC, synthesized from user's Perplexity research (2026-05-24). This is the spec we design against — replaces guesses about "cartoon feeling."

## What LFC actually is

- **Cozy hidden-object adventure** with a story campaign + bonus challenge levels + office decoration meta-loop
- **$17.99 premium one-time-purchase** on Steam (Windows + macOS) — NOT free-to-play, NOT mobile
- **Single-player, no time limits**, full English audio + subtitles in multiple languages
- **10+ launch levels** plus bonus challenge levels
- **15-20 hour completion time** (main story ~10 hours)

## Core gameplay loop

- Densely packed hand-crafted scenes — Steam page says "thousands of interactive characters and objects"
- **Two task lists per scene:** a main item list (required to complete the level) + a separate optional/side list (often harder)
- **Hint system uses a currency**, NOT a simple cooldown
  - Currency earned by finding small anomaly/goo-like objects scattered around the map
  - There's a secondary unlockable hint tier
  - No timer-based cooldown found in sources
- Almost everything in the scene is interactable (click triggers a sound or animation, even on non-objective elements)
- Light puzzle elements between/inside object-finding

## Progression

- Level-based, not free-roam
- Complete scene → earn gold → spend gold to **decorate Ducky's office/room** (cosmetic meta-loop)
- No evidence of star-gating, live-service mechanics, or paid unlocks past the initial purchase
- Replay value comes from finding side-list objects + cosmetic decoration goals

## Story + characters

- **Main characters: Ducky (duck-turned-human intern) and Goddess Mei** (running a lost-and-found business to regain her power)
- Story delivered via **chatbox dialogue + comic-style cutscenes** — NOT fully animated cinematics
- Recurring NPCs are quirky clients and townspeople inside levels
- Cast list beyond Ducky + Mei not fully verified, but the framing duo is THEM (not "orange-cap girl + pink axolotl" — that's a different game)

## Animation + reactivity

- World described as **highly animated and visually dense**
- Many independently moving elements per scene
- **Per-prop click sounds + character reaction noises confirmed**
- Cursor-follow / hover-glance / event-driven pose changes NOT confirmed by available sources
- Animation technique (frame-by-frame vs. skeletal-rigged) NOT confirmed

## Audio

- Music: chill, soothing, can become repetitive on long levels
- Per-prop SFX confirmed
- **NO voice acting confirmed** — text dialogue only

## Platform + business model

- Steam (Windows + macOS), $17.99 USD
- Steam Achievements, Steam Cloud, Family Sharing
- Premium one-time purchase — opposite of mobile F2P
- Session length flexible: pick up, finish a level, set down

---

## What this changes vs. our master plan

The original `cozy_hidden_object_game_master_plan (1).md` (in `/Users/santipapmay/Downloads/`) targets:

| Aspect | Master plan | LFC reality | Reconciliation needed |
|---|---|---|---|
| Price | $7.99 | $17.99 | LFC is 2x our target — we're competing on price OR underselling |
| Scenes | 10 | 10+ launch, plus bonus levels | Aligned |
| Per-scene length | 5-15 min | Longer, story-paced | LFC scenes hold attention longer |
| Total content | ~2-3 hours | 15-20 hours | LFC is 5-10x our content target |
| Story | Light frame, no dialogue trees | Chatbox dialogue + comic cutscenes | We'd need a writer + dialogue system |
| Hint system | 60-sec cooldown, 3/scene | Currency-based, earned by finding anomalies | Our current implementation is simpler |
| Meta-loop | None planned | Decorate Ducky's room with earned gold | Major missing feature |
| Task structure | Single item list | Main list + side/optional list | We have single-list HUD only |
| Mascots | 1 planned (we dropped per user) | Ducky + Mei as story characters (not framing) | Different role entirely |

## What this changes vs. our current Godot project state

**Mechanics:**
- Our current single-list HUD is wrong — need main + side lists
- Our hint cooldown is wrong — need currency-based hints + anomaly objects to find for currency
- We have no story, no chatbox, no cutscene support — need those for LFC parity
- We have no meta-loop (decoration, gold spending) — that's a whole second game system

**Visuals:**
- ⚠️ **CRITICAL: The reference screenshot we locked (`iso_throwaway_05.png` — isometric cutaway flat-vector mobile-style) may NOT be LFC.** LFC is a premium PC Steam game with densely-packed 2D scenes and chatbox dialogue. That's a different aesthetic from the Toca-Boca isometric mobile look.
- The previous reference image the user shared (with "Find all the socks 5/10" + multi-floor toggle + categorical HUD) is almost certainly a DIFFERENT cozy mobile HOG game (possibly "Tiny Tales," "My Family," or similar).
- This needs reconciliation before more Codex art is generated.

## Recommended next discussion points

1. **Visual style:** Is the iso_throwaway_05 living room actually the look you want, or do you want LFC's denser hand-painted 2D style (which is closer to what the master plan originally specced as "soft-painted storybook")?
2. **Story system:** Do you want chatbox dialogue + cutscenes (LFC) or stay light-frame (master plan)? This is a big build either way.
3. **Hint mechanics:** Switch from cooldown to currency-based? Adds gameplay depth, requires more design.
4. **Meta-loop:** Add a decoration/customization layer? Multiplies project scope.
5. **Price target:** Stay at $7.99 (master plan) or align with LFC at $14.99-$17.99?

## Sources

- https://store.steampowered.com/app/2101390/Lost_and_Found_Co/
- https://boilingsteam.com/lost-and-found-co/
- https://imalwaystired.blog/2026/03/14/highlights-magazine-for-all-ages-lost-found-co/
- YouTube reviews (Boiling Steam + others)
- Reddit r/WhatsOnSteam discussion
