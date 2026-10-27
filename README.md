# EMBERFALL: THE THREE TRIALS
### Production-Quality 3D Roguelike Action Game (Godot 4.5.x / 4.7.x)

---

## 1. GAME OVERVIEW & VISION

**Emberfall: The Three Trials** is a dark fantasy, third-person isometric 3D action roguelike inspired by the fluid combat, chamber progression, and permanent upgrade loops of *Hades*. 

Players take up the glowing runeblade of an ancient Knight to brave the three sacred chambers of the fallen citadel, battling aggressive Imps, lumbering Puglin brutes, and the towering final boss: **The Ashen Warden**.

---

## 2. THE THREE TRIALS & UNIQUE LEVEL ASPECTS

Each trial features an enclosed, bounded arena built with seamless modular stone architecture, perimeter walls, corner columns, and dynamic gameplay modifiers:

1. **Trial I: The Ashen Court (`res://scenes/levels/ashen_court.tscn`)**
   - *Theme:* An ancient fortress courtyard abandoned after a catastrophic battle.
   - *Arena Bounds:* 24m × 24m seamless stone flagstone floor enclosed by solid ramparts and braziers.
   - *Level Aspect:* **Trial of Steel** — Core melee fundamentals, dash timing, and combo mastery.
   - *Wave Structure (2 Waves):*
     - **Wave 1:** 3 Goblin Imps (skirmisher intro with flanking orbits).
     - **Wave 2 (Reinforcements):** 2 Imps + 2 Puglin Brutes (shock trooper frontline).
   - *Reward:* Unseals the Relic Chest and opens the Chamber Exit Gate upon final wave clearance.

2. **Trial II: The Obsidian Gallery (`res://scenes/levels/obsidian_gallery.tscn`)**
   - *Theme:* A subterranean temple constructed from obsidian and corrupted cyan crystals.
   - *Arena Bounds:* 28m × 28m expanded arena flanked by massive crystal columns.
   - *Level Aspect:* **Trial of Resilience** — Player dash recovery speed is accelerated by 30% (`Dash Surge`), while gallery monstrosities gain +15% damage resilience (`Hardened Carapace`).
   - *Wave Structure (3 Waves):*
     - **Wave 1:** 3 Imps (fast crystal scouts).
     - **Wave 2:** 2 Puglins + 1 Imp (heavy enforcer charge).
     - **Wave 3 (Climactic Wave):** 3 Imps + 2 Puglin Brutes.
   - *Reward:* Unlocks the portal staircase to the summit sanctuary.

3. **Trial III: The Ember Throne (`res://scenes/levels/ember_throne.tscn`)**
   - *Theme:* A monumental volcanic throne room surrounded by basalt walls and blazing fire braziers.
   - *Arena Bounds:* 32m × 32m grand arena centered on the sacred Hearthfire.
   - *Level Aspect:* **Trial of Flame** — Player Ember Burst cooldown is halved (from 5.0s down to 2.5s) through ambient fire resonance, while the boss gains furious enrage mechanics.
   - *Boss Encounter:* **THE ASHEN WARDEN — GUARDIAN OF THE FLAME**
     - **Phase 1 (100%–50% HP):** Greatsword cleaves (telegraphed), lunging thrusts, and directional ground charges.
     - **Phase 2 (Enraged <50% HP):** Increased movement speed, molten shockwaves, full-arena Molten Hellfire area bursts, and summons **2 Minion Imps** into the arena.
   - *Victory:* Defeating the warden grants permanent shards and triggers the cinematic **Victory of the Embers** sequence.

---

## 3. GAMEPLAY CONTROLS

The control scheme separates character navigation entirely to the keyboard, keeping the mouse dedicated strictly to combat strikes:

| Action | Input | Description |
|---|---|---|
| **Move & Direction Facing** | `W, A, S, D` / `Arrow Keys` | Full 8-directional movement. The Knight dynamically turns and faces the movement direction automatically using smooth angular interpolation. |
| **Runeblade Strike** | `Left Mouse Button` | Executes a weapon swing with animated slash arcs, spark impacts, knockback, and screen shake. |
| **Roll / Dash** | `Spacebar` | Rapid directional dash with invulnerability frames (i-frames) and cooldown meter on the HUD. |
| **Ember Burst** | `Q` | 360-degree radial fiery shockwave dealing heavy damage and knockback to all surrounding foes. |
| **Interact** | `E` | Open relic chests and activate chamber exit gates. |
| **Pause Menu** | `Escape` | Pause combat, inspect controls, spend shards, or restart run. |

---

## 4. CHARACTERS, ANIMATIONS & WEAPONS

- **Knight Player:** Rigged 3D model with attached glowing Runic Blade mounted directly to the right hand, emitting ambient light and particles.
- **Skeletal Animations:** All characters utilize embedded 3D skeletal animations from the Universal Character Pack:
  - `Knight_Male.gltf`: Seamlessly transitions between `Idle`, `Run`, `SwordSlash`, `RecieveHit`, and `Death`.
  - `Goblin_Male.gltf` (Imp): Agile melee strikes, evasive running, hit flinches, and death collapses.
  - `Zombie_Male.gltf` (Puglin Brute): Heavy lumbering walk, telegraphed overhead slams, shockwave generation, and death falls.
  - `Knight_Golden_Male.gltf` (The Ashen Warden): Scaled to 1.45x, equipped with `Sword_Golden.obj`, golden armor, and distinct attack animations.
- **Animation System:** Implements fuzzy animation matching to ensure compatibility regardless of model name prefixes (`Idle`, `Knight_Male/Idle`, etc.).

---

## 5. ROGUELIKE PROGRESSION & VICTORY SEQUENCE

- **Run Embers:** Ephemeral run currency earned by vanquishing enemies and opening relic chests.
- **Sanctuary Shards:** Permanent meta-currency preserved across runs and automatically saved to `user://emberfall_progression.json`.
- **Permanent Sanctuary Upgrades:**
  1. *Titan's Vitality:* +20 Max HP per level (Base 100 HP) with instant health restoration.
  2. *Ember Blade:* +15% Melee Attack Damage per level.
  3. *Cataclysm Burst:* +25% Ember Burst Damage per level.
  4. *Shadow Flight:* -15% Dash Recovery Cooldown per level.
- **Victory Screen:** Upon conquering Trial III, players are presented with a decorated victory card containing a developer Thank You message, narrative epilogue, total run embers forged, permanent shards collected, and buttons to embark on another trial or visit the Sanctuary.

---

## 6. PROJECT ARCHITECTURE & FILE TREE

```
res://
  ├── project.godot                     # Godot 4.5/4.7 project configuration
  ├── icon.svg                          # Project vector icon
  ├── assets/
  │   ├── characters/                   # Knight_Male.gltf, Knight_Golden_Male.gltf, Goblin_Male.gltf, Zombie_Male.gltf
  │   ├── enemies/                      # Imp.glb, Puglin.glb, textures
  │   ├── weapons/                      # Sword.obj, Sword_Golden.obj, materials
  │   ├── dungeon/                      # Modular KayKit floors, walls, columns, torches
  │   ├── audio/                        # Kenney impact, slash, hit, stomp SFX
  │   └── particles/                    # Kenney ember, spark, smoke textures
  ├── scenes/
  │   ├── main/
  │   │   ├── main.tscn                 # Entry scene
  │   │   ├── main_menu.tscn            # Dark fantasy menu & controls
  │   │   ├── game_over.tscn            # Run death screen & shard preservation
  │   │   └── victory.tscn              # Thank You card & victory sequence
  │   ├── player/
  │   │   ├── player.tscn               # Fully assembled Knight player scene
  │   │   ├── player_weapon.tscn        # Glowing runic sword scene
  │   │   └── player_hitbox.tscn        # Frontal attack hitbox
  │   ├── enemies/
  │   │   ├── imp.tscn                  # Fast melee Goblin Imp scene
  │   │   └── puglin.tscn               # Heavy brute Zombie Puglin scene
  │   ├── boss/
  │   │   ├── boss.tscn                 # The Ashen Warden boss scene
  │   │   └── boss_weapon.tscn          # Golden greatsword scene
  │   ├── levels/
  │   │   ├── ashen_court.tscn          # Trial 1 arena (24x24m bounded)
  │   │   ├── obsidian_gallery.tscn     # Trial 2 arena (28x28m bounded)
  │   │   ├── ember_throne.tscn         # Trial 3 boss arena (32x32m bounded)
  │   │   └── exit_gate.tscn            # Chamber exit doorway
  │   ├── combat/
  │   │   ├── hit_effect.tscn           # Impact spark particles
  │   │   ├── slash_effect.tscn         # Melee glowing crescent arc
  │   │   ├── ember_burst_effect.tscn   # Radial fiery shockwave
  │   │   ├── attack_telegraph.tscn     # Red danger warning zone
  │   │   └── damage_number.tscn        # Floating damage labels
  │   ├── pickups/
  │   │   ├── ember_pickup.tscn         # Magnetic ember orb
  │   │   └── upgrade_reward.tscn       # Relic chest
  │   └── ui/
  │       ├── hud.tscn                  # Master gameplay HUD
  │       ├── boss_health_bar.tscn      # The Ashen Warden health bar
  │       ├── upgrade_selection.tscn    # 3-Card upgrade selection modal
  │       └── pause_menu.tscn           # In-game pause menu
  ├── scripts/
  │   ├── managers/                     # GameManager, ProgressionManager, AudioManager
  │   ├── player/                       # PlayerController
  │   ├── enemies/                      # EnemyBase, ImpEnemy, PuglinEnemy
  │   ├── boss/                         # AshenWardenBoss
  │   ├── levels/                       # RoomController, ExitGate, RewardChest
  │   ├── combat/                       # Visual effects and combat entities
  │   └── ui/                           # HUDController, MainMenu, UpgradeSelection, VictoryController
  ├── tests/
  │   ├── test_emberfall.gd             # Automated GDScript test suite
  │   └── test_runner.tscn              # Test runner scene
  └── docs/
      ├── asset_inventory.md            # Asset compatibility, models, and licenses
      └── editor_guide.md               # Guide to editing scenes in Godot Editor
```

---

## 7. HOW TO RUN THE PROJECT & TESTS

### Opening in Godot Editor
1. Launch **Godot Engine 4.5.x** (or **Godot 4.7.x**).
2. Click **Import** and browse to this directory (`d:/Projects/yash_cg`).
3. Select `project.godot` and click **Import & Edit**.
4. Press **F5** (or the Play button in top right) to run the game from `scenes/main/main.tscn`.

### Running Automated Static Integrity Checks
Run the following PowerShell command in the project folder:
```powershell
powershell -ExecutionPolicy Bypass -File run_static_checks.ps1
```
*Result: 121 checks executed and passed (0 errors).*

### Running In-Engine Automated Test Suite
Open Godot and run the test scene directly:
- Set `tests/test_runner.tscn` as the current scene and press **F6** (Run Current Scene).
#   C G - E m b e r f a l l  
 