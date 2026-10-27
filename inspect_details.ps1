Add-Type -AssemblyName System.IO.Compression.FileSystem

$zips = @(
    "Bestiary - Dungeon Monsters Kit[Standard].zip",
    "KayKit_Dungeon_Pack_1.1_FREE.zip",
    "Ultimate Animated Character Pack - Nov 2019-20261026T204646Z-1-001.zip",
    "Medieval Weapons Pack by @Quaternius-20261026T204920Z-1-001.zip"
)

foreach ($zName in $zips) {
    $path = Join-Path "d:\Projects\yash_cg\Assets" $zName
    if (Test-Path $path) {
        Write-Host "=== DETAILS FOR: $zName ==="
        $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($path)
        $all = $zipArchive.Entries | Select-Object -ExpandProperty FullName
        Write-Host "Total Files: $($all.Count)"
        
        # Look for key patterns
        $monsters = $all | Where-Object { $_ -match "imp|pug|golem|boss|skeleton|demon|dragon|warden|orc|beast|monster|minotaur" }
        if ($monsters) {
            Write-Host "-- Key Monsters/Enemies matched: --"
            $monsters | Select-Object -First 30 | ForEach-Object { Write-Host "   $_" }
        }
        
        $anims = $all | Where-Object { $_ -match "anim|idle|walk|run|attack|slash|hit|death|jump" }
        if ($anims) {
            Write-Host "-- Key Animations/Clips: --"
            $anims | Select-Object -First 30 | ForEach-Object { Write-Host "   $_" }
        }

        $dungeonProps = $all | Where-Object { $_ -match "\.(gltf|glb|fbx|obj)$" }
        Write-Host "-- Total 3D Models: $($dungeonProps.Count) --"
        $dungeonProps | Select-Object -First 15 | ForEach-Object { Write-Host "   $_" }

        $zipArchive.Dispose()
    }
}
