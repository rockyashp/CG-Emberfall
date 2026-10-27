# Godot Editor Design Guide: Emberfall

This guide explains how to edit and extend rooms, characters, props, spawn points, and combat values directly within the **Godot 4.5 Scene Dock** and **3D Viewport**.

Every gameplay object in Emberfall is built as a real, editable `.tscn` scene. You never need to edit hardcoded code to change visual positions or layout.

---

## 1. Editing Rooms & Arenas

The three rooms are located under `res://scenes/levels/`:
- `ashen_court.tscn` (Level 1)
- `obsidian_gallery.tscn` (Level 2)
- `ember_throne.tscn` (Level 3)

### How to customize a room:
1. Double click any room scene (e.g., `ashen_court.tscn`) in the **FileSystem** dock to open it.
2. In the **Scene** tree:
   - Expand `EnvironmentRoot/Floors` to select and move floor tiles.
   - Expand `EnvironmentRoot/Columns` to move, scale, or duplicate stone pillars.
   - Expand `EnvironmentRoot/WallsStatic` to adjust boundary collision boxes.
   - Expand `EnvironmentRoot/WallModels` to place additional decorative wall segments.
3. Select `WorldEnvironment` or `DirectionalLight3D` in the Scene tree to alter ambient lighting, shadow angle, or sky colors in the **Inspector** dock.

---

## 2. Adjusting Player & Enemy Spawn Points

In each room scene:
- **Player Start Position:** Select the `PlayerSpawn` node (Marker3D). Use the 3D gizmo to drag it anywhere on the arena floor.
- **Enemy Entry Positions:** Select the `SpawnPoints` node. Its child markers (`Spawn1`, `Spawn2`, etc.) represent enemy entry markers. 
  - To add a new spawn location, simply duplicate (`Ctrl + D`) any marker and drag it to a new location.
- **Exit Gate:** Select the `ExitGate` node and reposition it against any desired doorway or arch.
- **Relic Chest:** Select the `RewardChest` node and position it anywhere in the room.

---

## 3. Configuring Encounter Difficulty & Enemy Waves

Select the root node of any level scene (e.g., `AshenCourt`):
In the **Inspector** dock on the right, you will see exported variables:
- `imp_spawn_count` (Default: 4) — Number of fast melee Imps to spawn.
- `puglin_spawn_count` (Default: 2) — Number of heavy Puglins to spawn.
- `room_name` — Display name shown on the HUD upon chamber entry.

---

## 4. Tuning Combat Stats & Ability Balance

### Player Combat Values
Open `res://scenes/player/player.tscn`:
Select the root `Player` node. In the **Inspector**:
- `move_speed` (Default: 7.0) — Walking/running velocity.
- `dash_speed` (Default: 17.0) — Speed during roll/dash.
- `dash_duration` (Default: 0.22) — Duration of dash in seconds.
- `base_damage` (Default: 28.0) — Base melee damage before upgrades.
- `burst_cooldown_max` (Default: 6.0) — Cooldown of Ember Burst in seconds.

### Enemy Stats
- **Imp (`res://scenes/enemies/imp.tscn`):**
  - `max_hp` (Default: 42.0)
  - `move_speed` (Default: 5.6)
  - `attack_damage` (Default: 12.0)
  - `windup_duration` (Default: 0.38)
- **Puglin (`res://scenes/enemies/puglin.tscn`):**
  - `max_hp` (Default: 85.0)
  - `move_speed` (Default: 3.2)
  - `attack_damage` (Default: 22.0)
  - `attack_range` (Default: 2.6)
- **The Ashen Warden Boss (`res://scenes/boss/boss.tscn`):**
  - `max_hp` (Default: 380.0)
  - `move_speed` (Default: 4.2)
  - `phase_2_speed_multiplier` (Default: 1.35)

---

## 5. Adding New Props & Modular Pieces

From `res://assets/dungeon/`, you can drag and drop any of the 200+ modular glTF models directly into the 3D Viewport:
- `torch_mounted.gltf` / `torch.gltf`
- `banner_shield_red.gltf` / `banner_blue.gltf`
- `rubble.gltf` / `trunk_large_A.gltf`
- `wall_arched.gltf` / `wall_doorway.gltf`

All modular models share the unified `dungeon_texture.png` palette, ensuring visual cohesion.
