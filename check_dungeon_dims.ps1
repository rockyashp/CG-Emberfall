$content = Get-Content "d:\Projects\yash_cg\assets\dungeon\floor_tile_large.gltf" -Raw
$json = ConvertFrom-Json $content
$p = $json.accessors | Where-Object { $_.type -eq "VEC3" -and $_.min -and $_.max } | Select-Object -First 1
Write-Host "Floor tile bounds: Min: ($($p.min -join ', ')) | Max: ($($p.max -join ', '))"

$wContent = Get-Content "d:\Projects\yash_cg\assets\dungeon\wall.gltf" -Raw
$wJson = ConvertFrom-Json $wContent
$wp = $wJson.accessors | Where-Object { $_.type -eq "VEC3" -and $_.min -and $_.max } | Select-Object -First 1
Write-Host "Wall bounds: Min: ($($wp.min -join ', ')) | Max: ($($wp.max -join ', '))"
