$lines = Get-Content "d:\Projects\yash_cg\assets\weapons\Sword.obj"
$vLines = $lines | Where-Object { $_ -match "^v\s+" }
$ys = $vLines | ForEach-Object { ($_ -split "\s+")[2] -as [float] } | Measure-Object -Minimum -Maximum
$xs = $vLines | ForEach-Object { ($_ -split "\s+")[1] -as [float] } | Measure-Object -Minimum -Maximum
$zs = $vLines | ForEach-Object { ($_ -split "\s+")[3] -as [float] } | Measure-Object -Minimum -Maximum
Write-Host "Sword OBJ bounds:"
Write-Host "X: $($xs.Minimum) to $($xs.Maximum)"
Write-Host "Y: $($ys.Minimum) to $($ys.Maximum)"
Write-Host "Z: $($zs.Minimum) to $($zs.Maximum)"
