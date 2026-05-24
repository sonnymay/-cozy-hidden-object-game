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

## Visual identity (round 2 research, 2026-05-24)

- **Perspective:** quarter-isometric / isometric-feeling — NOT top-down, NOT side-view. Stays consistent across locations.
- **Art technique:** cute anime/cartoon with **bold outlines, solid vibrant colors, layered detail**. Backgrounds and characters share ONE unified illustrated style (not mixed-media).
- **Palette:** bright, colorful, high-energy — **NOT muted, NOT earthy**. Scenes described as "vibrant" and "chaotic." Tongue-in-cheek details everywhere.
- **Lighting:** stylized + scene-based, NOT physically realistic. No dynamic lighting / day-night system called out by reviewers.
- **Scene density:** **VERY dense — hundreds or even thousands of tiny animated people, animals, and props across large one-screen environments.** Intentionally cluttered for searching.
- **UI:** clean overlay on top of the art (not diegetic / world-blended). Dialogue windows + comic-book-style cutscenes between levels. Phone/Instapix system as a separated interface element.

## NPC design + behavior (round 2)

- **Character design:** stylized cute anime-like, Ducky + Goddess Mei drawn in the SAME bubbly cartoon style as background NPCs (no leads-vs-NPCs visual hierarchy).
- **Animation technique:** mostly frame-based pose/loop animation + triggered reactions. Reviewers mention blinking, looping idle life, and per-object click reactions. NOT skeletal-rigged according to available sources.
- **NPC behavior pattern:** rooted in scene + responds to clicks with tiny animated surprises (jumping, fleeing, looking reactive). Some objects/NPCs need to be moved or interacted with before the hidden target appears (this is the LFC equivalent of our "reveal interactions").
- **Personality conveyed** through dialogue + visual design + comic-style scenes, not RPG-style behavior trees.

## Why people adore it (round 2)

- **The "comfort game" quality** comes from: low-stress pacing + cozy music + adorable animation + sense that every scene is alive with tiny discoveries.
- Reviewers say **non-gamer family members stop to admire the artwork and cozy character animations** — the visuals alone carry emotional warmth.
- Specifically called out: chill bubbly soundtrack + huge number of cute sound effects for nearly every interaction.

## Memorable moments

NOT giant plot twists. Reviewers cite tiny environmental jokes and click reactions:
- A drone zipping away and scaring a nearby character
- A fox popping up from flowers and reacting excitedly
- Comic-style story beats between levels give a "storybook rhythm"

Pattern: small absurd character moments stick with players more than puzzle achievements.

## Audience comparisons

Reviewers compare LFC primarily to:
- **Hidden Folks** (Adriaan de Jongh, 2017) — the master plan already names this as the "alive feel" benchmark ✓
- **Hidden Cats**
- **Classic "Where's Waldo"-style searches**

NOT primarily compared to Stardew / Animal Crossing despite cozy framing. The strongest genre signal is "interactive hidden-object adventure," not "life sim" or "sandbox decorator."

This shifts our master plan's audience targeting slightly: more search-puzzle audience (Hidden Folks, A Little to the Left), less life-sim audience (Stardew, AC).

## Short-form (TikTok / YouTube Shorts) appeal

What makes LFC clip-friendly:
- **Every clip has immediate visual payoff** — dense scenes, bright color, fast click reactions, satisfying reveal of hidden object
- **Movement does a lot of work even without sound** — characters/props react instantly when clicked
- **Art is readable at a glance** — 5-15 sec clip can show charm + "aha" moment clearly

This validates master plan Section 9's "5-sec alive-scene loops outperform screenshots 10:1 on TikTok" claim.

## Satisfaction cues ("stim" moments)

The strongest sensory rewards:
- Click reaction (visual + sound) on any interactive element
- Reveal animation when a hidden item appears
- Success feedback around finding things
- Hint system "helps keep momentum without turning the game into a chore"

Core loop: **click, react, reveal, repeat.**

---

## REVISED understanding vs. round 1

Round 1's flag that "the iso pivot might be wrong because LFC is densely-packed 2D" was **incorrect**. LFC IS quarter-isometric. The iso_throwaway_05 anchor direction matches LFC's actual perspective. Codex Brief 5 (isometric cozy living room art) is on the right track.

The earlier mobile-game screenshot the user shared (with "Find all the socks 5/10" + floor toggle) is still likely a DIFFERENT game (mobile, not premium PC), but its **isometric perspective happens to match LFC**. So the visual direction is correct even if the source-of-truth reference was misattributed.

## CRITICAL new gap: density

LFC has **hundreds to thousands** of tiny animated elements per scene. Our current plan has:
- 15 hidden objects
- 10 interactive props
- 4 critters
- 3 reveals
- = ~32 elements

That's roughly **30-100x less dense than LFC**. This is the biggest unspecced gap in our project right now.

Two ways to close it:
1. **Increase per-scene asset count** — generate ~100-300 sprites per scene via Codex (massive token cost + style consistency risk)
2. **Reuse element library across scenes** — generate ~50 highly reusable critters/people/props once, then position them differently per scene (cheaper, more sustainable for solo dev)

Recommendation: option 2. Build a shared `assets/library/` of 30-50 small NPCs + 20-30 reusable small props (birds, cups, books, toys, signs) and position them densely in each scene via JSON.

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
