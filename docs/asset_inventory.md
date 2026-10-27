# Asset Inventory: Emberfall — The Three Trials

## 1. Character & Boss Assets

| File Path | Asset Type | Intended Use | Skeleton & Animations | Texture Dependencies | License | Import / Setup Steps |
|---|---|---|---|---|---|---|
| `assets/characters/Knight_Male.gltf` | glTF 2.0 with embedded buffers | Player Character (Knight) | 25 bones (`CharacterArmature`, `Fist.R`, `Fist.L`, `Head`, `Torso`, etc.). 17 embedded clips: `Idle`, `Run`, `Walk`, `SwordSlash`, `RecieveHit`, `Death`, `Roll`, `Jump`, `Victory`. | Self-contained / embedded vertex colors & textures. | CC0 1.0 Universal (Quaternius) | Direct glTF import; attach weapon to `CharacterArmature/Skeleton3D/Fist.R` via `BoneAttachment3D`. |
| `assets/characters/Knight_Golden_Male.gltf` | glTF 2.0 with embedded buffers | Final Boss: The Ashen Warden | Identical rig to Knight (`CharacterArmature`, `Fist.R`, etc.). 17 embedded clips: `Idle`, `Run`, `SwordSlash`, `RecieveHit`, `Death`, `Roll`, `Victory`. | Self-contained / embedded golden plate armor textures. | CC0 1.0 Universal (Quaternius) | Boss scene root with scale 1.4x for imposing boss stature; sword attachment on `Fist.R`; boss state machine driving Phase 1 & Phase 2. |
| `assets/characters/Zombie_Male.gltf` | glTF 2.0 with embedded buffers | Secondary Dungeon Undead / Ghoul enemy | Identical rig to Knight (`CharacterArmature`). 17 embedded clips: `Idle`, `Walk`, `Run`, `Punch`, `RecieveHit`, `Death`. | Self-contained textures. | CC0 1.0 Universal (Quaternius) | Enemy scene with melee strikes and hit/death reactions. |
| `assets/characters/Goblin_Male.gltf` | glTF 2.0 with embedded buffers | Alternative / Fast Scavenger enemy | Identical rig to Knight (`CharacterArmature`). 17 embedded clips: `Idle`, `Run`, `SwordSlash`, `RecieveHit`, `Death`. | Self-contained textures. | CC0 1.0 Universal (Quaternius) | Direct import; fast locomotion. |

---

## 2. Bestiary Enemy Assets

| File Path | Asset Type | Intended Use | Skeleton & Animations | Texture Dependencies | License | Import / Setup Steps |
|---|---|---|---|---|---|---|
| `assets/enemies/Imp.glb` | GLB (glTF Binary) | Level 1 & 2 Standard Fast Melee Enemy (Imp) | 61 humanoid bones (`Head`, `neck_01`, `pelvis`, `spine_01`, `hand_l`, `hand_r`). No embedded animation clips. | `T_Imp_BaseColor_1.png`, `T_Imp_Normal.png`, `T_Imp_Emissive.png`, `T_Imp_ORM.png`. | Standard Free / CC0 (Quaternius) | Procedural animation state machine (breathing, lunging melee strike with distinct wind-up, recoil hit flash, death dissolve). |
| `assets/enemies/Puglin.glb` | GLB (glTF Binary) | Level 2 Tank / Heavy Cadence Enemy (Puglin) | 59 humanoid bones (`Head`, `neck_01`, `pelvis`, `spine_01`, `hand_l`, `hand_r`). No embedded animation clips. | `T_Puglin_BaseColor_1.png`, `T_Puglin_Normal.png`, `T_Puglin_Emissive.png`, `T_Puglin_ORM.png`. | Standard Free / CC0 (Quaternius) | Distinct lumbering cadence, area ground stomp / club attack, heavy armor posture. |

---

## 3. Modular Environment Assets (KayKit Dungeon Pack)

| File Path | Asset Type | Intended Use | Collision & Setup | Texture Dependencies | License | Notes |
|---|---|---|---|---|---|---|
| `assets/dungeon/floor_tile_large.gltf` | glTF + bin | Modular stone courtyard and temple floors | StaticBody3D with BoxShape3D collision | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Core walkable ground for Ashen Court, Obsidian Gallery, and Ember Throne. |
| `assets/dungeon/wall.gltf` & `wall_corner.gltf` | glTF + bin | Arena boundary walls | StaticBody3D with BoxShape3D collision | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Keep player and enemies inside combat boundaries. |
| `assets/dungeon/wall_doorway.gltf` / `gate.gltf` | glTF + bin | Locked/Unlocked Room Exits | Area3D trigger when room cleared | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Visually clear doorway leading to next trial. |
| `assets/dungeon/column.gltf` & `pillar.gltf` | glTF + bin | Ruined architecture, columns, obstacles | StaticBody3D obstacle collision | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Adds architectural depth, cover and combat lanes. |
| `assets/dungeon/torch_mounted.gltf` / `torch.gltf` | glTF + bin | Environmental braziers and wall torches | OmniLight3D with warm ember / obsidian crystal glow | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Creates rich dark fantasy lighting atmosphere. |
| `assets/dungeon/chest.gltf` | glTF + bin | Relic / Upgrade reward chest | Interactive reward marker upon arena clearance | `dungeon_texture.png` (relative) | CC0 1.0 Universal (Kay Lousberg) | Triggers upgrade selection screen. |

---

## 4. Weapons & Combat Equipment

| File Path | Asset Type | Intended Use | Scaling & Orientation | License | Notes |
|---|---|---|---|---|---|
| `assets/weapons/Sword.obj` + `Sword.mtl` | Wavefront OBJ | Player Knight's Main Runeblade | Scaled ~1.0, attached to `BoneAttachment3D` on right fist | CC0 1.0 Universal (Quaternius) | Aligned hand grip with clean blade silhouette. |
| `assets/weapons/Sword_Golden.obj` | Wavefront OBJ | The Ashen Warden Boss Greatsword | Scaled ~1.5, attached to Boss right hand | CC0 1.0 Universal (Quaternius) | Monumental golden blade for heavy telegraphed swings. |
| `assets/weapons/Claymore.obj` / `Hammer_Double.obj` | Wavefront OBJ | Heavy secondary / alternative weapons | Aligned to hand bone transforms | CC0 1.0 Universal (Quaternius) | High quality medieval weapon set. |

---

## 5. Audio & Visual Effects Assets

| File Path | Asset Type | Intended Use | License | Notes |
|---|---|---|---|---|
| `assets/audio/impactMetal_heavy_*.ogg` | Ogg Vorbis Audio | Melee sword slashes, clashing hits, parries | CC0 1.0 Universal (Kenney) | Punchy combat feedback. |
| `assets/audio/impactWood_heavy_*.ogg` | Ogg Vorbis Audio | Heavy impacts, enemy footsteps, ground slams | CC0 1.0 Universal (Kenney) | Boss slam and dash feedback. |
| `assets/audio/impactPlate_heavy_*.ogg` | Ogg Vorbis Audio | Armor impacts, boss phase transitions | CC0 1.0 Universal (Kenney) | Metallic armor hits. |
| `assets/particles/*.png` | PNG Textures (Alpha) | Ember bursts, slash trails, fire sparks, dust | CC0 1.0 Universal (Kenney) | Used in GPUParticles3D and CPUParticles3D for magical bursts and attack telegraphs. |
