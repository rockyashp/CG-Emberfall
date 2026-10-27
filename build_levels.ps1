# Script to construct complete, gapless, bounded rooms with walls, floors, pillars, and lighting
$baseDir = "d:\Projects\yash_cg"

function Generate-Level1 {
    # Ashen Court: 6x6 grid (-10 to +10, step 4)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('[gd_scene load_steps=15 format=3 uid="uid://ashncourt01"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/levels/room_controller.gd" id="1_ctrl"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://scenes/levels/exit_gate.tscn" id="2_gate"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://scenes/pickups/upgrade_reward.tscn" id="3_chest"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/floor_tile_large.gltf" id="4_floor"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/wall.gltf" id="5_wall"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/column.gltf" id="6_col"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_ashen"]')
    [void]$sb.AppendLine('sky_top_color = Color(0.18, 0.12, 0.22, 1)')
    [void]$sb.AppendLine('sky_horizon_color = Color(0.4, 0.25, 0.18, 1)')
    [void]$sb.AppendLine('ground_bottom_color = Color(0.1, 0.08, 0.12, 1)')
    [void]$sb.AppendLine('ground_horizon_color = Color(0.3, 0.18, 0.14, 1)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Sky" id="Sky_ashen"]')
    [void]$sb.AppendLine('sky_material = SubResource("ProceduralSkyMaterial_ashen")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Environment" id="Environment_ashen"]')
    [void]$sb.AppendLine('background_mode = 2')
    [void]$sb.AppendLine('sky = SubResource("Sky_ashen")')
    [void]$sb.AppendLine('ambient_light_source = 2')
    [void]$sb.AppendLine('ambient_light_color = Color(0.35, 0.28, 0.24, 1)')
    [void]$sb.AppendLine('ambient_light_energy = 0.85')
    [void]$sb.AppendLine('tonemap_mode = 2')
    [void]$sb.AppendLine('glow_enabled = true')
    [void]$sb.AppendLine('glow_intensity = 0.8')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_floor"]')
    [void]$sb.AppendLine('size = Vector3(32, 1, 32)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_h"]')
    [void]$sb.AppendLine('size = Vector3(30, 6, 1.2)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_v"]')
    [void]$sb.AppendLine('size = Vector3(1.2, 6, 30)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="CylinderShape3D" id="CylinderShape3D_col"]')
    [void]$sb.AppendLine('height = 4.5')
    [void]$sb.AppendLine('radius = 0.7')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="AshenCourt" type="Node3D"]')
    [void]$sb.AppendLine('script = ExtResource("1_ctrl")')
    [void]$sb.AppendLine('room_name = "The Ashen Court"')
    [void]$sb.AppendLine('imp_spawn_count = 4')
    [void]$sb.AppendLine('puglin_spawn_count = 2')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WorldEnvironment" type="WorldEnvironment" parent="."]')
    [void]$sb.AppendLine('environment = SubResource("Environment_ashen")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(0.866025, -0.353553, 0.353553, 0, 0.707107, 0.707107, -0.5, -0.612372, 0.612372, 0, 16, 0)')
    [void]$sb.AppendLine('light_color = Color(1, 0.85, 0.72, 1)')
    [void]$sb.AppendLine('light_energy = 1.3')
    [void]$sb.AppendLine('shadow_enabled = true')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="EnvironmentRoot" type="Node3D" parent="."]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="FloorStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 7')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="CollisionShape3D" type="CollisionShape3D" parent="EnvironmentRoot/FloorStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_floor")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Floors" type="Node3D" parent="EnvironmentRoot"]')
    
    # 6x6 floor grid: X from -10 to +10, Z from -10 to +10, step 4
    $coords = @(-10, -6, -2, 2, 6, 10)
    $fIdx = 0
    foreach ($z in $coords) {
        foreach ($x in $coords) {
            [void]$sb.AppendLine("[node name=""Floor_$fIdx"" parent=""EnvironmentRoot/Floors"" instance=ExtResource(""4_floor"")]")
            [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $x, 0, $z)")
            $fIdx++
        }
    }
    
    # Walls Static Collision
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallsStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 6')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallN" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, -12.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallS" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 12.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallW" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12.5, 3, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallE" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12.5, 3, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    
    # Visual Walls around perimeter
    [void]$sb.AppendLine('[node name="WallModels" type="Node3D" parent="EnvironmentRoot"]')
    # North Wall (skip center for doorway arch)
    $wIdx = 0
    foreach ($wx in @(-10, -6, 6, 10)) {
        [void]$sb.AppendLine("[node name=""WallN_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, -12)")
        $wIdx++
    }
    # South Wall
    foreach ($wx in @(-10, -6, -2, 2, 6, 10)) {
        [void]$sb.AppendLine("[node name=""WallS_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, 12)")
        $wIdx++
    }
    # West Wall (rotated 90 deg)
    foreach ($wz in @(-10, -6, -2, 2, 6, 10)) {
        [void]$sb.AppendLine("[node name=""WallW_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, -12, 0, $wz)")
        $wIdx++
    }
    # East Wall (rotated 90 deg)
    foreach ($wz in @(-10, -6, -2, 2, 6, 10)) {
        [void]$sb.AppendLine("[node name=""WallE_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 12, 0, $wz)")
        $wIdx++
    }
    
    # Columns in the 4 corners and decorative interior
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Columns" type="Node3D" parent="EnvironmentRoot"]')
    $colPositions = @(
        @(-12, -12), @(12, -12), @(-12, 12), @(12, 12),
        @(-6, -6), @(6, -6), @(-6, 6), @(6, 6)
    )
    $cIdx = 0
    foreach ($cp in $colPositions) {
        $cx = $cp[0]
        $cz = $cp[1]
        [void]$sb.AppendLine("[node name=""Column_$cIdx"" type=""StaticBody3D"" parent=""EnvironmentRoot/Columns""]")
        [void]$sb.AppendLine("transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, $cx, 0, $cz)")
        [void]$sb.AppendLine("[node name=""ColShape"" type=""CollisionShape3D"" parent=""EnvironmentRoot/Columns/Column_$cIdx""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.2, 0)")
        [void]$sb.AppendLine("shape = SubResource(""CylinderShape3D_col"")")
        [void]$sb.AppendLine("[node name=""ColModel"" parent=""EnvironmentRoot/Columns/Column_$cIdx"" instance=ExtResource(""6_col"")]")
        $cIdx++
    }
    
    # Torches & Lights
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Torches" type="Node3D" parent="EnvironmentRoot"]')
    $torchPos = @(@(-6, 2.8, -6), @(6, 2.8, -6), @(-6, 2.8, 6), @(6, 2.8, 6), @(0, 3.2, -11.5))
    $tIdx = 0
    foreach ($tp in $torchPos) {
        $tx = $tp[0]; $ty = $tp[1]; $tz = $tp[2]
        [void]$sb.AppendLine("[node name=""Torch_$tIdx"" type=""OmniLight3D"" parent=""EnvironmentRoot/Torches""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $tx, $ty, $tz)")
        [void]$sb.AppendLine("light_color = Color(1, 0.62, 0.22, 1)")
        [void]$sb.AppendLine("light_energy = 2.4")
        [void]$sb.AppendLine("omni_range = 7.5")
        $tIdx++
    }
    
    # Spawns, Exit, Chest
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="PlayerSpawn" type="Marker3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, 7)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="SpawnPoints" type="Node3D" parent="."]')
    [void]$sb.AppendLine('[node name="Spawn1" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -4.5, 0.1, -4)')
    [void]$sb.AppendLine('[node name="Spawn2" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 4.5, 0.1, -4)')
    [void]$sb.AppendLine('[node name="Spawn3" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5, 0.1, 2)')
    [void]$sb.AppendLine('[node name="Spawn4" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 0.1, 2)')
    [void]$sb.AppendLine('[node name="Spawn5" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, -7)')
    [void]$sb.AppendLine('[node name="Spawn6" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, -1)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="ExitGate" parent="." instance=ExtResource("2_gate")]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -12)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="RewardChest" parent="." instance=ExtResource("3_chest")]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3.5, 0, -10)')
    
    Set-Content -Path "$baseDir\scenes\levels\ashen_court.tscn" -Value $sb.ToString()
    Write-Host "Generated seamless Level 1: ashen_court.tscn"
}

function Generate-Level2 {
    # Obsidian Gallery: 7x7 grid (-12 to +12, step 4)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('[gd_scene load_steps=15 format=3 uid="uid://obsidngall02"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/levels/room_controller.gd" id="1_ctrl"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://scenes/levels/exit_gate.tscn" id="2_gate"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://scenes/pickups/upgrade_reward.tscn" id="3_chest"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/floor_tile_large.gltf" id="4_floor"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/wall.gltf" id="5_wall"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/column.gltf" id="6_col"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_obsidian"]')
    [void]$sb.AppendLine('sky_top_color = Color(0.04, 0.08, 0.16, 1)')
    [void]$sb.AppendLine('sky_horizon_color = Color(0.12, 0.28, 0.35, 1)')
    [void]$sb.AppendLine('ground_bottom_color = Color(0.02, 0.04, 0.08, 1)')
    [void]$sb.AppendLine('ground_horizon_color = Color(0.08, 0.18, 0.25, 1)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Sky" id="Sky_obsidian"]')
    [void]$sb.AppendLine('sky_material = SubResource("ProceduralSkyMaterial_obsidian")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Environment" id="Environment_obsidian"]')
    [void]$sb.AppendLine('background_mode = 2')
    [void]$sb.AppendLine('sky = SubResource("Sky_obsidian")')
    [void]$sb.AppendLine('ambient_light_source = 2')
    [void]$sb.AppendLine('ambient_light_color = Color(0.18, 0.32, 0.42, 1)')
    [void]$sb.AppendLine('ambient_light_energy = 0.9')
    [void]$sb.AppendLine('tonemap_mode = 2')
    [void]$sb.AppendLine('glow_enabled = true')
    [void]$sb.AppendLine('glow_intensity = 0.9')
    [void]$sb.AppendLine('glow_bloom = 0.2')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_floor"]')
    [void]$sb.AppendLine('size = Vector3(36, 1, 36)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_h"]')
    [void]$sb.AppendLine('size = Vector3(34, 7, 1.2)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_v"]')
    [void]$sb.AppendLine('size = Vector3(1.2, 7, 34)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="CylinderShape3D" id="CylinderShape3D_col"]')
    [void]$sb.AppendLine('height = 5.5')
    [void]$sb.AppendLine('radius = 0.8')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="ObsidianGallery" type="Node3D"]')
    [void]$sb.AppendLine('script = ExtResource("1_ctrl")')
    [void]$sb.AppendLine('room_name = "The Obsidian Gallery"')
    [void]$sb.AppendLine('imp_spawn_count = 5')
    [void]$sb.AppendLine('puglin_spawn_count = 3')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WorldEnvironment" type="WorldEnvironment" parent="."]')
    [void]$sb.AppendLine('environment = SubResource("Environment_obsidian")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(0.707107, -0.5, 0.5, 0, 0.707107, 0.707107, -0.707107, -0.5, 0.5, 0, 18, 0)')
    [void]$sb.AppendLine('light_color = Color(0.7, 0.92, 1, 1)')
    [void]$sb.AppendLine('light_energy = 1.1')
    [void]$sb.AppendLine('shadow_enabled = true')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="EnvironmentRoot" type="Node3D" parent="."]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="FloorStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 7')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="CollisionShape3D" type="CollisionShape3D" parent="EnvironmentRoot/FloorStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_floor")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Floors" type="Node3D" parent="EnvironmentRoot"]')
    
    # 7x7 floor grid: X from -12 to +12, Z from -12 to +12, step 4
    $coords7 = @(-12, -8, -4, 0, 4, 8, 12)
    $fIdx = 0
    foreach ($z in $coords7) {
        foreach ($x in $coords7) {
            [void]$sb.AppendLine("[node name=""Floor_$fIdx"" parent=""EnvironmentRoot/Floors"" instance=ExtResource(""4_floor"")]")
            [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $x, 0, $z)")
            $fIdx++
        }
    }
    
    # Walls Static Collision
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallsStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 6')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallN" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.5, -14.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallS" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.5, 14.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallW" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -14.5, 3.5, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallE" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 14.5, 3.5, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    
    # Wall Models
    [void]$sb.AppendLine('[node name="WallModels" type="Node3D" parent="EnvironmentRoot"]')
    $wIdx = 0
    foreach ($wx in @(-12, -8, -4, 4, 8, 12)) {
        [void]$sb.AppendLine("[node name=""WallN_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, -14)")
        $wIdx++
    }
    foreach ($wx in @(-12, -8, -4, 0, 4, 8, 12)) {
        [void]$sb.AppendLine("[node name=""WallS_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, 14)")
        $wIdx++
    }
    foreach ($wz in @(-12, -8, -4, 0, 4, 8, 12)) {
        [void]$sb.AppendLine("[node name=""WallW_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, -14, 0, $wz)")
        $wIdx++
    }
    foreach ($wz in @(-12, -8, -4, 0, 4, 8, 12)) {
        [void]$sb.AppendLine("[node name=""WallE_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""5_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 14, 0, $wz)")
        $wIdx++
    }
    
    # Columns
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Columns" type="Node3D" parent="EnvironmentRoot"]')
    $colPositions2 = @(
        @(-14, -14), @(14, -14), @(-14, 14), @(14, 14),
        @(-8, -8), @(8, -8), @(-8, 8), @(8, 8)
    )
    $cIdx = 0
    foreach ($cp in $colPositions2) {
        $cx = $cp[0]; $cz = $cp[1]
        [void]$sb.AppendLine("[node name=""Column_$cIdx"" type=""StaticBody3D"" parent=""EnvironmentRoot/Columns""]")
        [void]$sb.AppendLine("transform = Transform3D(1.4, 0, 0, 0, 1.4, 0, 0, 0, 1.4, $cx, 0, $cz)")
        [void]$sb.AppendLine("[node name=""ColShape"" type=""CollisionShape3D"" parent=""EnvironmentRoot/Columns/Column_$cIdx""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.7, 0)")
        [void]$sb.AppendLine("shape = SubResource(""CylinderShape3D_col"")")
        [void]$sb.AppendLine("[node name=""ColModel"" parent=""EnvironmentRoot/Columns/Column_$cIdx"" instance=ExtResource(""6_col"")]")
        $cIdx++
    }
    
    # Cyan Crystal Lights
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="CrystalLights" type="Node3D" parent="EnvironmentRoot"]')
    $crystalPos = @(@(-8, 3.2, -8), @(8, 3.2, -8), @(-8, 3.2, 8), @(8, 3.2, 8), @(0, 3.5, -13.5))
    $crIdx = 0
    foreach ($cp in $crystalPos) {
        $cx = $cp[0]; $cy = $cp[1]; $cz = $cp[2]
        [void]$sb.AppendLine("[node name=""CrystalLight_$crIdx"" type=""OmniLight3D"" parent=""EnvironmentRoot/CrystalLights""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $cx, $cy, $cz)")
        [void]$sb.AppendLine("light_color = Color(0.2, 0.85, 1, 1)")
        [void]$sb.AppendLine("light_energy = 2.8")
        [void]$sb.AppendLine("omni_range = 8.5")
        $crIdx++
    }
    
    # Spawns, Exit, Chest
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="PlayerSpawn" type="Marker3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, 9)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="SpawnPoints" type="Node3D" parent="."]')
    [void]$sb.AppendLine('[node name="Spawn1" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6, 0.1, -5)')
    [void]$sb.AppendLine('[node name="Spawn2" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 6, 0.1, -5)')
    [void]$sb.AppendLine('[node name="Spawn3" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6.5, 0.1, 3)')
    [void]$sb.AppendLine('[node name="Spawn4" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 6.5, 0.1, 3)')
    [void]$sb.AppendLine('[node name="Spawn5" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, -9)')
    [void]$sb.AppendLine('[node name="Spawn6" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, 0)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="ExitGate" parent="." instance=ExtResource("2_gate")]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -14)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="RewardChest" parent="." instance=ExtResource("3_chest")]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -4.5, 0, -11.5)')
    
    Set-Content -Path "$baseDir\scenes\levels\obsidian_gallery.tscn" -Value $sb.ToString()
    Write-Host "Generated seamless Level 2: obsidian_gallery.tscn"
}

function Generate-Level3 {
    # Ember Throne: 8x8 grid (-14 to +14, step 4)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('[gd_scene load_steps=14 format=3 uid="uid://embrthrn03"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/levels/room_controller.gd" id="1_ctrl"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://scenes/levels/exit_gate.tscn" id="2_gate"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/floor_tile_large.gltf" id="3_floor"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/wall.gltf" id="4_wall"]')
    [void]$sb.AppendLine('[ext_resource type="PackedScene" path="res://assets/dungeon/column.gltf" id="5_col"]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_throne"]')
    [void]$sb.AppendLine('sky_top_color = Color(0.22, 0.05, 0.03, 1)')
    [void]$sb.AppendLine('sky_horizon_color = Color(0.6, 0.22, 0.06, 1)')
    [void]$sb.AppendLine('ground_bottom_color = Color(0.12, 0.03, 0.02, 1)')
    [void]$sb.AppendLine('ground_horizon_color = Color(0.42, 0.12, 0.04, 1)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Sky" id="Sky_throne"]')
    [void]$sb.AppendLine('sky_material = SubResource("ProceduralSkyMaterial_throne")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="Environment" id="Environment_throne"]')
    [void]$sb.AppendLine('background_mode = 2')
    [void]$sb.AppendLine('sky = SubResource("Sky_throne")')
    [void]$sb.AppendLine('ambient_light_source = 2')
    [void]$sb.AppendLine('ambient_light_color = Color(0.5, 0.22, 0.1, 1)')
    [void]$sb.AppendLine('ambient_light_energy = 1.05')
    [void]$sb.AppendLine('tonemap_mode = 2')
    [void]$sb.AppendLine('glow_enabled = true')
    [void]$sb.AppendLine('glow_intensity = 1.0')
    [void]$sb.AppendLine('glow_bloom = 0.25')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_floor"]')
    [void]$sb.AppendLine('size = Vector3(40, 1, 40)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_h"]')
    [void]$sb.AppendLine('size = Vector3(38, 8, 1.2)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_wall_v"]')
    [void]$sb.AppendLine('size = Vector3(1.2, 8, 38)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="CylinderShape3D" id="CylinderShape3D_col"]')
    [void]$sb.AppendLine('height = 6.5')
    [void]$sb.AppendLine('radius = 1.0')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[sub_resource type="BoxShape3D" id="BoxShape3D_throne"]')
    [void]$sb.AppendLine('size = Vector3(8, 4, 3)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="EmberThrone" type="Node3D"]')
    [void]$sb.AppendLine('script = ExtResource("1_ctrl")')
    [void]$sb.AppendLine('room_name = "The Ember Throne"')
    [void]$sb.AppendLine('is_boss_room = true')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WorldEnvironment" type="WorldEnvironment" parent="."]')
    [void]$sb.AppendLine('environment = SubResource("Environment_throne")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(0.866025, -0.433013, 0.25, 0, 0.5, 0.866025, -0.5, -0.75, 0.433013, 0, 20, 0)')
    [void]$sb.AppendLine('light_color = Color(1, 0.58, 0.2, 1)')
    [void]$sb.AppendLine('light_energy = 1.45')
    [void]$sb.AppendLine('shadow_enabled = true')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="EnvironmentRoot" type="Node3D" parent="."]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="FloorStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 7')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="CollisionShape3D" type="CollisionShape3D" parent="EnvironmentRoot/FloorStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_floor")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Floors" type="Node3D" parent="EnvironmentRoot"]')
    
    # 8x8 floor grid: X from -14 to +14, Z from -14 to +14, step 4
    $coords8 = @(-14, -10, -6, -2, 2, 6, 10, 14)
    $fIdx = 0
    foreach ($z in $coords8) {
        foreach ($x in $coords8) {
            [void]$sb.AppendLine("[node name=""Floor_$fIdx"" parent=""EnvironmentRoot/Floors"" instance=ExtResource(""3_floor"")]")
            [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $x, 0, $z)")
            $fIdx++
        }
    }
    
    # Walls Static Collision
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallsStatic" type="StaticBody3D" parent="EnvironmentRoot"]')
    [void]$sb.AppendLine('collision_layer = 1')
    [void]$sb.AppendLine('collision_mask = 6')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallN" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 4, -16.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallS" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 4, 16.5)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_h")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallW" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -16.5, 4, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="WallE" type="CollisionShape3D" parent="EnvironmentRoot/WallsStatic"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16.5, 4, 0)')
    [void]$sb.AppendLine('shape = SubResource("BoxShape3D_wall_v")')
    [void]$sb.AppendLine('')
    
    # Wall Models
    [void]$sb.AppendLine('[node name="WallModels" type="Node3D" parent="EnvironmentRoot"]')
    $wIdx = 0
    foreach ($wx in @(-14, -10, -6, 6, 10, 14)) {
        [void]$sb.AppendLine("[node name=""WallN_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""4_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, -16)")
        $wIdx++
    }
    foreach ($wx in @(-14, -10, -6, -2, 2, 6, 10, 14)) {
        [void]$sb.AppendLine("[node name=""WallS_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""4_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $wx, 0, 16)")
        $wIdx++
    }
    foreach ($wz in @(-14, -10, -6, -2, 2, 6, 10, 14)) {
        [void]$sb.AppendLine("[node name=""WallW_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""4_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, -16, 0, $wz)")
        $wIdx++
    }
    foreach ($wz in @(-14, -10, -6, -2, 2, 6, 10, 14)) {
        [void]$sb.AppendLine("[node name=""WallE_$wIdx"" parent=""EnvironmentRoot/WallModels"" instance=ExtResource(""4_wall"")]")
        [void]$sb.AppendLine("transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 16, 0, $wz)")
        $wIdx++
    }
    
    # Monumental Columns
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="MonumentalColumns" type="Node3D" parent="EnvironmentRoot"]')
    $colPositions3 = @(
        @(-16, -16), @(16, -16), @(-16, 16), @(16, 16),
        @(-10, -10), @(10, -10), @(-10, 10), @(10, 10)
    )
    $cIdx = 0
    foreach ($cp in $colPositions3) {
        $cx = $cp[0]; $cz = $cp[1]
        [void]$sb.AppendLine("[node name=""Pillar_$cIdx"" type=""StaticBody3D"" parent=""EnvironmentRoot/MonumentalColumns""]")
        [void]$sb.AppendLine("transform = Transform3D(1.6, 0, 0, 0, 1.6, 0, 0, 0, 1.6, $cx, 0, $cz)")
        [void]$sb.AppendLine("[node name=""ColShape"" type=""CollisionShape3D"" parent=""EnvironmentRoot/MonumentalColumns/Pillar_$cIdx""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.2, 0)")
        [void]$sb.AppendLine("shape = SubResource(""CylinderShape3D_col"")")
        [void]$sb.AppendLine("[node name=""ColModel"" parent=""EnvironmentRoot/MonumentalColumns/Pillar_$cIdx"" instance=ExtResource(""5_col"")]")
        $cIdx++
    }
    
    # Molten Lava Braziers
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="Braziers" type="Node3D" parent="EnvironmentRoot"]')
    $brazierPos = @(@(-6, 2.5, -13), @(6, 2.5, -13), @(-10, 2.5, 0), @(10, 2.5, 0), @(0, 3.5, -15.5))
    $bIdx = 0
    foreach ($bp in $brazierPos) {
        $bx = $bp[0]; $by = $bp[1]; $bz = $bp[2]
        [void]$sb.AppendLine("[node name=""BrazierLight_$bIdx"" type=""OmniLight3D"" parent=""EnvironmentRoot/Braziers""]")
        [void]$sb.AppendLine("transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, $bx, $by, $bz)")
        [void]$sb.AppendLine("light_color = Color(1, 0.45, 0.05, 1)")
        [void]$sb.AppendLine("light_energy = 3.6")
        [void]$sb.AppendLine("omni_range = 9.0")
        $bIdx++
    }
    
    # Spawns & Exit
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="PlayerSpawn" type="Marker3D" parent="."]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, 11)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="SpawnPoints" type="Node3D" parent="."]')
    [void]$sb.AppendLine('[node name="BossSpawn" type="Marker3D" parent="SpawnPoints"]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.1, -5)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[node name="ExitGate" parent="." instance=ExtResource("2_gate")]')
    [void]$sb.AppendLine('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -16)')
    
    Set-Content -Path "$baseDir\scenes\levels\ember_throne.tscn" -Value $sb.ToString()
    Write-Host "Generated seamless Level 3: ember_throne.tscn"
}

Generate-Level1
Generate-Level2
Generate-Level3
