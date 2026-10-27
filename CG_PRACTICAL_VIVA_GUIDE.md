# EMBERFALL: THE THREE TRIALS
## Computer Graphics (CG) Practical Viva Examination Reference Manual

This manual provides an in-depth breakdown of **EMBERFALL: The Three Trials** for academic and practical viva evaluations in Computer Graphics, Game Engine Architecture, and Real-Time Interactive Simulation.

---

# 1. Project High-Level Architecture

* **Engine:** Godot Engine 4.5.x / 4.7.x
* **Renderer Backend:** Forward+ (Clustered PBR, Vulkan / Direct3D 12)
* **Base Resolution:** 1280 × 720 (16:9 Aspect Ratio)
* **Physics Tick Rate:** 60 Hz fixed timestep (`_physics_process(delta)` with $\Delta t \approx 0.01667\text{ s}$)
* **Coordinate System:** Right-Handed Cartesian ($+X$ = Right, $+Y$ = Up, $+Z$ = Forward / Camera-facing)

### System Architecture Diagram
```
                           +----------------------------+
                           |        SceneTree /         |
                           |   Main Loop (60 Hz Tick)   |
                           +--------------+-------------+
                                          |
                +-------------------------+-------------------------+
                |                         |                         |
     +----------v----------+   +----------v----------+   +----------v----------+
     |   GameManager       |   | ProgressionManager  |   |   AudioManager      |
     |   (Autoload)        |   | (Disk Persistence)  |   | (16-Channel Pool)   |
     +----------+----------+   +----------+----------+   +---------------------+
                |                         |
                +-------------------------+
                                          |
                               +----------v----------+
                               |     Main.tscn       |
                               +----------+----------+
                                          |
                     +--------------------+--------------------+
                     |                                         |
          +----------v----------+                   +----------v----------+
          |   RoomController    |                   |     CanvasLayer     |
          |  (Geometry & Waves) |                   |    (HUD & Modals)   |
          +----------+----------+                   +---------------------+
                     |
        +------------+------------+
        |                         |
+-------v-------+         +-------v-------+
|  Player Node  | <=====> | Enemy / Boss  |
| (CharBody3D)  | Hitbox  | (CharBody3D)  |
+---------------+         +---------------+
```

---

# 2. Computer Graphics Concepts & Mathematical Principles

### 2.1 Coordinate Systems & Transformations
Geometry passes through 5 distinct coordinate spaces:
$$\mathbf{v}_{\text{screen}} = \mathbf{M}_{\text{viewport}} \cdot \mathbf{M}_{\text{proj}} \cdot \mathbf{M}_{\text{view}} \cdot \mathbf{M}_{\text{model}} \cdot \mathbf{v}_{\text{local}}$$

1. **Object / Local Space:** Coordinates relative to the model's pivot point $(0,0,0)$.
2. **World Space:** The unified Cartesian space transformed by `Transform3D` ($3 \times 3$ Basis + $3 \times 1$ Origin).
3. **View / Eye Space:** Transformed relative to the active camera. The camera uses a fixed $-55^\circ$ pitch and isometric height $(0, 11.5, 7.8)$.
4. **Clip / Normalized Device Coordinates (NDC):** Scaled into $[-1, 1]^3$ via the Perspective Projection Matrix ($48^\circ\text{ FOV}$).
5. **Screen / Window Space:** Transformed to the $1280 \times 720$ viewport raster grid.

#### Key Math Equations Used in Code:
* **Vector Normalization:**
  $$\hat{\mathbf{v}} = \frac{\mathbf{v}}{\|\mathbf{v}\|} = \frac{(x, y, z)}{\sqrt{x^2 + y^2 + z^2}}$$
  Used in `player_controller.gd` to prevent diagonal speed boosting.
* **Heading from Input Keys ($\text{atan2}$):**
  $$\theta = \text{atan2}(-v_x, -v_z)$$
  Converts directional WASD inputs directly into a horizontal yaw angle without mouse dependency.
* **Spherical Angular Interpolation (`lerp_angle`):**
  $$\theta_{t+\Delta t} = \theta_t + \text{wrap}_{(-\pi, \pi)}(\theta_{\text{target}} - \theta_t) \cdot (1 - e^{-\lambda \Delta t})$$
  Eliminates angle discontinuities across the $\pm 180^\circ$ boundary.

---

### 2.2 Physically Based Rendering (PBR) & Illumination
Implemented using the **Cook-Torrance Microfacet Specular BRDF**:
$$f_r(\mathbf{\omega}_i, \mathbf{\omega}_o) = k_d \frac{\rho}{\pi} + k_s \frac{D(\mathbf{h}) \cdot F(\mathbf{\omega}_o, \mathbf{h}) \cdot G(\mathbf{\omega}_i, \mathbf{\omega}_o, \mathbf{h})}{4 (\mathbf{n} \cdot \mathbf{\omega}_i)(\mathbf{n} \cdot \mathbf{\omega}_o)}$$

* **Normal Distribution $D(\mathbf{h})$ (GGX):** Determines microfacet roughness and specular highlight shape.
* **Fresnel-Schlick $F(\mathbf{\omega}_o, \mathbf{h})$:** Computes grazing-angle reflectivity:
  $$F(\theta) = F_0 + (1 - F_0)(1 - \cos\theta)^5$$
* **Smith Masking-Shadowing $G$:** Accounts for self-occlusion among microfacets.
* **Material Channels:**
  - **Albedo:** Base diffuse color (`dungeon_texture.png`).
  - **Roughness:** $0.1$ for reflective polished runeblades; $0.85$ for porous stone walls.
  - **Metallic:** $1.0$ for gold boss armor; $0.0$ for stone/flesh.
  - **Emission:** HDR radiance multiplier ($E = I \cdot c$). Used on the glowing runeblade ($4.0\times$), summoning glyphs, and molten lava trenches.
* **Inverse-Square Light Attenuation:**
  $$E = \frac{I_0}{\max(d^2, \epsilon)}$$
  Calculated in real-time for torch lights, weapon glow, and particle flashes.

---

### 2.3 Skeletal Rigging & Linear Blend Skinning (LBS)
Characters are deformed using **Linear Blend Skinning (Matrix Palette Skinning)**:
$$\mathbf{v}' = \sum_{i=1}^{M} w_i \cdot \mathbf{M}_i \cdot \mathbf{B}_i^{-1} \cdot \mathbf{v}$$

* $\mathbf{v}$: Rest-pose vertex.
* $\mathbf{B}_i^{-1}$: Inverse Bind Pose Matrix of bone $i$.
* $\mathbf{M}_i$: Transformed bone matrix.
* $w_i$: Normalized skin weight ($\sum w_i = 1.0$).
* **Forward Kinematics Bone Attachment:**
  The glowing runeblade is dynamically attached to bone `"Fist.R"` via `BoneAttachment3D`:
  $$\mathbf{T}_{\text{weapon\_world}} = \mathbf{T}_{\text{skeleton\_world}} \cdot \mathbf{M}_{\text{Fist.R}} \cdot \mathbf{T}_{\text{offset}}$$

---

### 2.4 Particle Systems & Camera-Facing Billboards
* **Billboard Math:** Vertices rotate to align their normal vector directly with the camera's view vector:
  $$\mathbf{R}_{\text{particle}} = \begin{bmatrix} \hat{\mathbf{u}}_{\text{cam}} & \hat{\mathbf{v}}_{\text{cam}} & \hat{\mathbf{w}}_{\text{cam}} \end{bmatrix}$$
* **Kinematics:** $\mathbf{p}(t) = \mathbf{p}_0 + \mathbf{v}_0 t + \frac{1}{2} \mathbf{a} t^2$.
* **Additive Blending:** $C_{\text{final}} = C_{\text{src}} + C_{\text{dest}}$ for fire sparks, shockwave rings, and ember pick-up glow.

---

### 2.5 Physics & Kinematic Slide Collision
* **Slide Resolution (`move_and_slide()`):**
  Resolves collision penetration along surface normals:
  $$\mathbf{v}_{\text{slide}} = \mathbf{v} - (\mathbf{v} \cdot \hat{\mathbf{n}}) \hat{\mathbf{n}}$$
* **Velocity Drag & Exponential Decay:**
  $$\mathbf{v}_{t+\Delta t} = \text{lerp}(\mathbf{v}_t, \mathbf{0}, k \Delta t)$$
* **Collision Layers & Masks:**
  - Layer 1: World Environment
  - Layer 2: Player Body
  - Layer 3: Enemy Bodies
  - Layer 4: Player Attack Hitboxes (Scans Layer 3)
  - Layer 5: Enemy Attack Hitboxes (Scans Layer 2)
  - Layer 6: Pickups & Collectibles

---

### 2.6 Flocking & Steering Vectors
* **Craig Reynolds' Flocking Separation:**
  $$\mathbf{F}_{\text{sep}} = \sum_{j \in \text{Neighbors}} \frac{\mathbf{p}_i - \mathbf{p}_j}{\max(\|\mathbf{p}_i - \mathbf{p}_j\|^2, 0.01)}$$
  Prevents clustering by applying a repulsive force between enemies closer than $1.4\text{m}$.
* **Orthogonal Flanking Vector:**
  $$\mathbf{v}_{\text{orbit}} = \hat{\mathbf{v}}_{\text{pursuit}} \times (0, 1, 0)$$
  Used by Imp Skirmishers to circle the player before lunging.

---

# 3. Exhaustive Script Breakdown (`scripts/`)

### Managers (`scripts/managers/`)
1. **`game_manager.gd`**: Autoload singleton. Coordinates chamber progression (`ashen_court` $\rightarrow$ `obsidian_gallery` $\rightarrow$ `ember_throne`), wave signals, ember currencies, and delayed transitions to `victory.tscn` ($2.8\text{s}$) or `game_over.tscn` ($2.2\text{s}$).
2. **`progression_manager.gd`**: Autoload singleton. Manages persistent Sanctuary Shards and upgrades (`vitality`, `strength`, `agility`, `resonance`) with quadratic pricing curves and JSON persistence (`user://emberfall_progression.json`).
3. **`audio_manager.gd`**: Autoload singleton. 16-channel round-robin polyphony pool (`AudioStreamPlayer`) with $\pm 8\%$ pitch randomization to prevent acoustic clipping.

### Player Controller (`scripts/player/`)
4. **`player_controller.gd`**: Kinematic character controller (`CharacterBody3D`). Computes keyboard-driven yaw using $\text{atan2}$, linear interpolation for rotation, dynamic bone attachment to `"Fist.R"`, 3-hit attack combo machine, and invulnerable dash kinematics ($16.5\text{ m/s}$).

### Enemy AI & Boss (`scripts/enemies/` & `scripts/boss/`)
5. **`enemy_base.gd`**: Polymorphic base class for all enemies. Contains Finite State Machine (IDLE, CHASE, ATTACK, HURT, DEAD), Reynolds separation steering, and fuzzy animation name matching.
6. **`imp_enemy.gd`**: Fast skirmisher AI. Calculates orthogonal orbit vectors to flank the player, lunges with claws, and executes a $-6.0\text{ m/s}$ evasive back-hop after attacking.
7. **`puglin_enemy.gd`**: Heavy brute AI. Executes close-range Seismic Ground Slams ($r=3.4\text{m}$) and medium-range Bull Rush charges ($11.5\text{ m/s}$) with telegraph lanes.
8. **`ashen_warden_boss.gd`**: 2-Phase final boss. Phase 1 features heavy sword cleaves and charges. Phase 2 (at $\le 50\%$ HP) triggers enrage: $+35\%$ speed, Molten Hellfire lava eruptions, and minion summoning.

### Combat & VFX (`scripts/combat/`)
9. **`attack_telegraph.gd`**: Dynamic ground decal that expands over attack windup times to warn the player.
10. **`damage_number.gd`**: Billboard `Label3D` that displays combat damage, rises vertically, and fades out.
11. **`ember_burst_effect.gd`**: Special AoE radial flame blast ($Q$ key). Expands a shockwave mesh ($r=5.5\text{m}$) and emits additive GPU particles.
12. **`ember_pickup.gd`**: Collectible ember item. Features sinusoidal vertical hover and accelerates toward the player via magnetic lerp within $4.5\text{m}$.
13. **`hit_effect.gd`**: High-velocity spark particles and an omnidirectional flash light on sword contact.
14. **`slash_effect.gd`**: Panned-UV ribbon arc mesh simulating the glowing blade trail.

### Levels (`scripts/levels/`)
15. **`room_controller.gd`**: Chamber orchestrator. Manages multi-wave enemy queues, spawns $0.55\text{s}$ pre-summon telegraph rings, tracks chamber modifiers, and spawns the reward chest upon clearing.
16. **`exit_gate.gd`**: Portal archway triggering transition to the next chamber upon player entry.
17. **`reward_chest.gd`**: Relic chest that presents the 3-card upgrade modal when opened.

### User Interface (`scripts/ui/` & `scripts/main/`)
18. **`hud.gd`**: Real-time HUD. Displays smoothed HP drain (`lerpf` at $14.0 \cdot \Delta t$), live numerical countdowns and fill bars for Dash and Burst, wave status (`⚔ WAVE X / Y — FOES: Z`), and animated announcement banners.
19. **`boss_health_bar.gd`**: Cinematic top-screen boss health bar with phase transition tags.
20. **`upgrade_selection.gd`**: 3-card upgrade modal displaying level transitions (`LEVEL 1 ➔ 2`) and Shard costs.
21. **`pause_menu.gd`**: Handles game pause state (`get_tree().paused = true`) and menu navigation.
22. **`main_menu.gd`**: Main menu handling run starts, controls panel, and Sanctuary upgrades.
23. **`game_over.gd`**: Death screen summarizing run stats and preserved shards.
24. **`victory.gd`**: Victory screen displaying completion stats and a developer Thank You message.
25. **`main.gd`**: Root scene bootstrapper.
26. **`test_emberfall.gd`**: In-engine assertion test suite for core gameplay math.

---

# 4. Exhaustive Scene Breakdown (`scenes/`)

1. **`boss/boss.tscn`**: Scaled golden knight model with capsule collider, weapon bone attachment, and telegraph markers.
2. **`boss/boss_weapon.tscn`**: Golden sword mesh with PBR metallic finish and hurtbox.
3. **`combat/attack_telegraph.tscn`**: Concentric scaling decal mesh for visual attack cues.
4. **`combat/damage_number.tscn`**: Billboard Label3D for floating combat numbers.
5. **`combat/ember_burst_effect.tscn`**: Torus shockwave mesh, radial particles, and dynamic light.
6. **`combat/hit_effect.tscn`**: Spark particle burst and light flash.
7. **`combat/slash_effect.tscn`**: Textured ribbon trail mesh.
8. **`enemies/imp.tscn`**: Fast goblin skirmisher with skeletal animations and bite hitbox.
9. **`enemies/puglin.tscn`**: Heavy zombie brute with slam and charge hitboxes.
10. **`levels/ashen_court.tscn`**: $24\text{m} \times 24\text{m}$ ($6 \times 6$) seamless arena. 2 waves.
11. **`levels/obsidian_gallery.tscn`**: $28\text{m} \times 28\text{m}$ ($7 \times 7$) arena with crystal pillars. 3 waves.
12. **`levels/ember_throne.tscn`**: $32\text{m} \times 32\text{m}$ ($8 \times 8$) basalt boss arena with lava hazards.
13. **`levels/exit_gate.tscn`**: Gateway arch with particle vortex and trigger area.
14. **`main/main.tscn`**: Game entry point scene.
15. **`main/main_menu.tscn`**: Title screen with styled dark fantasy cards.
16. **`main/game_over.tscn`**: Death card with retry and return options.
17. **`main/victory.tscn`**: Victory card with epilogue and developer credits.
18. **`pickups/ember_pickup.tscn`**: Floating octahedron with magnetic attraction.
19. **`pickups/upgrade_reward.tscn`**: Stone relic chest with interaction prompt.
20. **`player/player.tscn`**: Knight character, top-down camera rig, and dash timer.
21. **`player/player_hitbox.tscn`**: Standalone Area3D for sword cleaves.
22. **`player/player_weapon.tscn`**: Glowing runeblade with emissive material and point light.
23. **`ui/boss_health_bar.tscn`**: Cinematic health bar with phase indicators.
24. **`ui/hud.tscn`**: Full in-game HUD (HP, cooldowns, waves, shards).
25. **`ui/pause_menu.tscn`**: Glassmorphic pause panel.
26. **`ui/upgrade_selection.tscn`**: 3-card rogue-lite upgrade modal.
27. **`tests/test_runner.tscn`**: In-engine test runner.

---

# 5. Viva Rapid-Fire Examination Q&A

* **Q: Why Forward+ instead of Compatibility?**
  * *A:* Forward+ uses clustered forward shading to support dozens of real-time lights with full Cook-Torrance PBR and bloom without significant performance loss.
* **Q: How does the player face movement directions without the mouse?**
  * *A:* Using $\theta = \text{atan2}(-v_x, -v_z)$ calculated from keyboard input axes and smoothed via `lerp_angle()`.
* **Q: How is the weapon attached to the animated character?**
  * *A:* Using a `BoneAttachment3D` node bound to the `"Fist.R"` bone on `Skeleton3D`, inheriting the bone's world transform matrix each frame.
* **Q: How do enemies avoid overlapping?**
  * *A:* Through Craig Reynolds' Flocking Separation steering behavior: an inverse-distance repulsive force calculated from neighboring enemy positions.
* **Q: What is Linear Blend Skinning?**
  * *A:* Vertex skinning where each vertex position is computed as a weighted sum of bone transforms: $\mathbf{v}' = \sum w_i \mathbf{M}_i \mathbf{B}_i^{-1} \mathbf{v}$.
