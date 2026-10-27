Add-Type -AssemblyName System.IO.Compression.FileSystem

$baseDir = "d:\Projects\yash_cg"

# 1. Create target directories
$dirs = @(
    "assets/characters",
    "assets/enemies",
    "assets/weapons",
    "assets/dungeon",
    "assets/audio",
    "assets/particles",
    "scenes/main",
    "scenes/player",
    "scenes/enemies",
    "scenes/boss",
    "scenes/levels",
    "scenes/combat",
    "scenes/pickups",
    "scenes/ui",
    "scripts/managers",
    "scripts/player",
    "scripts/enemies",
    "scripts/boss",
    "scripts/combat",
    "scripts/levels",
    "scripts/ui",
    "scripts/progression",
    "resources/upgrades",
    "tests"
)

foreach ($d in $dirs) {
    $fullPath = Join-Path $baseDir $d
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

Write-Host "Target directories created."

# 2. Extract Characters from Ultimate Animated Character Pack
$charZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\Ultimate Animated Character Pack - Nov 2019-20261026T204646Z-1-001.zip")
$targetChars = @(
    "Knight_Male.gltf",
    "Knight_Golden_Male.gltf",
    "Zombie_Male.gltf",
    "Goblin_Male.gltf"
)

foreach ($tc in $targetChars) {
    $entry = $charZip.GetEntry("Ultimate Animated Character Pack - Nov 2019/glTF/$tc")
    if ($entry) {
        $dest = Join-Path "$baseDir\assets\characters" $tc
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
        Write-Host "Extracted character: $tc"
    }
}
$charZip.Dispose()

# 3. Extract Bestiary Imp & Puglin + Textures
$bestiaryZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\Bestiary - Dungeon Monsters Kit[Standard].zip")
foreach ($entry in $bestiaryZip.Entries) {
    if ($entry.FullName -match "GLB \(Godot-Unreal\)/([^/]+\.glb)$") {
        $dest = Join-Path "$baseDir\assets\enemies" $Matches[1]
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
        Write-Host "Extracted enemy GLB: $($Matches[1])"
    }
    elseif ($entry.FullName -match "Textures/([^/]+\.(png|jpg))$") {
        $dest = Join-Path "$baseDir\assets\enemies" $Matches[1]
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
$bestiaryZip.Dispose()

# 4. Extract KayKit Dungeon Pack gltf, bin, textures
$kaykitZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\KayKit_Dungeon_Pack_1.1_FREE.zip")
foreach ($entry in $kaykitZip.Entries) {
    if ($entry.FullName -match "Assets/gltf/([^/]+\.(gltf|bin|png))$") {
        $dest = Join-Path "$baseDir\assets\dungeon" $Matches[1]
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
Write-Host "Extracted KayKit dungeon assets."
$kaykitZip.Dispose()

# 5. Extract Weapons from Medieval Weapons Pack
$weapZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\Medieval Weapons Pack by @Quaternius-20261026T204920Z-1-001.zip")
foreach ($entry in $weapZip.Entries) {
    if ($entry.FullName -match "OBJ/([^/]+\.(obj|mtl))$") {
        $dest = Join-Path "$baseDir\assets\weapons" $Matches[1]
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
Write-Host "Extracted Medieval Weapons."
$weapZip.Dispose()

# 6. Extract Audio from kenney_impact-sounds
$audioZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\kenney_impact-sounds.zip")
foreach ($entry in $audioZip.Entries) {
    if ($entry.FullName -match "\.ogg$") {
        $fileName = [System.IO.Path]::GetFileName($entry.FullName)
        $dest = Join-Path "$baseDir\assets\audio" $fileName
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
Write-Host "Extracted audio sounds."
$audioZip.Dispose()

# 7. Extract Particles from kenney_particle-pack
$partZip = [System.IO.Compression.ZipFile]::OpenRead("$baseDir\Assets\kenney_particle-pack.zip")
foreach ($entry in $partZip.Entries) {
    if ($entry.FullName -match "PNG \(Black with alpha\)/([^/]+\.png)$") {
        $dest = Join-Path "$baseDir\assets\particles" $Matches[1]
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
Write-Host "Extracted particles."
$partZip.Dispose()

Write-Host "All assets successfully extracted into clean project structure!"
