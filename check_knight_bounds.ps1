$path = "d:\Projects\yash_cg\assets\characters\Knight_Male.gltf"
$content = Get-Content $path -Raw
$json = ConvertFrom-Json $content
Write-Host "Knight gltf accessors count: $($json.accessors.Count)"
# Find min and max bounds across accessors
$positions = $json.accessors | Where-Object { $_.type -eq "VEC3" -and $_.min -and $_.max }
foreach ($p in $positions) {
    Write-Host "Bound Min: ($($p.min -join ', ')) | Max: ($($p.max -join ', '))"
}
