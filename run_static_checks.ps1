# Static verification script for Emberfall project files
$baseDir = "d:\Projects\yash_cg"

Write-Host "======================================================="
Write-Host "   EMBERFALL STATIC INTEGRITY & VALIDATION SUITE       "
Write-Host "======================================================="

$errors = 0
$passed = 0

function Assert-Check($condition, $msg) {
    if ($condition) {
        $script:passed++
        Write-Host " [PASS] $msg" -ForegroundColor Green
    } else {
        $script:errors++
        Write-Host " [FAIL] $msg" -ForegroundColor Red
    }
}

# 1. Check project.godot
$projFile = Join-Path $baseDir "project.godot"
Assert-Check (Test-Path $projFile) "project.godot exists"

# 2. Check Autoloads in project.godot
$projContent = Get-Content $projFile -Raw
Assert-Check ($projContent -match 'run/main_scene="res://scenes/main/main.tscn"') "project.godot main_scene configured to res://scenes/main/main.tscn"
Assert-Check ($projContent -match 'ProgressionManager=') "ProgressionManager autoload configured"
Assert-Check ($projContent -match 'GameManager=') "GameManager autoload configured"
Assert-Check ($projContent -match 'AudioManager=') "AudioManager autoload configured"

# 3. Check All .gd scripts syntax and references
$gdFiles = Get-ChildItem -Path $baseDir -Filter "*.gd" -Recurse
Write-Host "`n>> Validating $($gdFiles.Count) GDScript files..."

foreach ($f in $gdFiles) {
    $content = Get-Content $f.FullName -Raw
    $rel = $f.FullName.Substring($baseDir.Length + 1)
    
    # Check for basic balanced braces and brackets
    $openParen = ([regex]::Matches($content, '\(')).Count
    $closeParen = ([regex]::Matches($content, '\)')).Count
    $openBrace = ([regex]::Matches($content, '\{')).Count
    $closeBrace = ([regex]::Matches($content, '\}')).Count
    $openBracket = ([regex]::Matches($content, '\[')).Count
    $closeBracket = ([regex]::Matches($content, '\]')).Count
    
    $balanced = ($openParen -eq $closeParen) -and ($openBrace -eq $closeBrace) -and ($openBracket -eq $closeBracket)
    Assert-Check $balanced "GDScript balanced brackets: $rel"
    
    # Check for banned obsolete Godot 3 methods
    $hasOldRect = $content -match "Rect2\s*\.\s*translated"
    Assert-Check (-not $hasOldRect) "No obsolete Rect2.translated in $rel"
    
    # Check variable named floor
    $hasFloorVar = $content -match "var\s+floor\s*[:=]"
    Assert-Check (-not $hasFloorVar) "No variable shadowed as 'floor' in $rel"
}

# 4. Check All .tscn scenes and verify ext_resource paths
$tscnFiles = Get-ChildItem -Path $baseDir -Filter "*.tscn" -Recurse
Write-Host "`n>> Validating $($tscnFiles.Count) TSCN Scene files..."

foreach ($t in $tscnFiles) {
    $content = Get-Content $t.FullName -Raw
    $rel = $t.FullName.Substring($baseDir.Length + 1)
    
    # Find all ext_resource paths
    $matches = [regex]::Matches($content, 'path="res://([^"]+)"')
    $allPathsExist = $true
    $missingPath = ""
    
    foreach ($m in $matches) {
        $resPath = $m.Groups[1].Value
        $diskPath = Join-Path $baseDir $resPath.Replace('/', '\')
        if (-not (Test-Path $diskPath)) {
            $allPathsExist = $false
            $missingPath = $resPath
            break
        }
    }
    
    Assert-Check $allPathsExist "All ext_resources exist on disk for $rel $(if (-not $allPathsExist) { "(Missing: $missingPath)" })"
}

# 5. Check Assets Presence
Write-Host "`n>> Validating Crucial Art & Audio Assets..."
Assert-Check (Test-Path "$baseDir\assets\characters\Knight_Male.gltf") "Knight_Male.gltf present"
Assert-Check (Test-Path "$baseDir\assets\characters\Knight_Golden_Male.gltf") "Knight_Golden_Male.gltf present (The Ashen Warden Boss)"
Assert-Check (Test-Path "$baseDir\assets\enemies\Imp.glb") "Imp.glb present"
Assert-Check (Test-Path "$baseDir\assets\enemies\Puglin.glb") "Puglin.glb present"
Assert-Check (Test-Path "$baseDir\assets\weapons\Sword.obj") "Sword.obj present"
Assert-Check (Test-Path "$baseDir\assets\weapons\Sword_Golden.obj") "Sword_Golden.obj present"
Assert-Check (Test-Path "$baseDir\assets\dungeon\floor_tile_large.gltf") "floor_tile_large.gltf present"
Assert-Check (Test-Path "$baseDir\assets\dungeon\wall.gltf") "wall.gltf present"
Assert-Check (Test-Path "$baseDir\assets\dungeon\column.gltf") "column.gltf present"
Assert-Check (Test-Path "$baseDir\assets\dungeon\dungeon_texture.png") "dungeon_texture.png present"
Assert-Check ((Get-ChildItem -Path "$baseDir\assets\audio" -Filter "*.ogg").Count -gt 5) "Kenney audio files present"

Write-Host "`n======================================================="
Write-Host "STATIC CHECK SUMMARY: $passed PASSED, $errors FAILED"
Write-Host "======================================================="

if ($errors -eq 0) {
    Write-Host ">> ALL STATIC INTEGRITY VERIFICATIONS PASSED! <<" -ForegroundColor Green
} else {
    Write-Host ">> ERRORS DETECTED! <<" -ForegroundColor Red
}
