$lines = Get-Content 'd:\Projects\yash_cg\assets\weapons\Sword.obj'
$minX = 999.0; $maxX = -999.0
$minY = 999.0; $maxY = -999.0
$minZ = 999.0; $maxZ = -999.0
foreach ($line in $lines) {
    if ($line.StartsWith('v ')) {
        $parts = $line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        $x = [float]$parts[1]; $y = [float]$parts[2]; $z = [float]$parts[3]
        if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
        if ($z -lt $minZ) { $minZ = $z }; if ($z -gt $maxZ) { $maxZ = $z }
    }
}
Write-Host "X: $minX to $maxX (Width: $($maxX - $minX))"
Write-Host "Y: $minY to $maxY (Height/Length: $($maxY - $minY))"
Write-Host "Z: $minZ to $maxZ (Depth: $($maxZ - $minZ))"
