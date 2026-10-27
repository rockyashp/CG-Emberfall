Add-Type -AssemblyName System.IO.Compression.FileSystem

$path = "d:\Projects\yash_cg\Assets\KayKit_Dungeon_Pack_1.1_FREE.zip"
$zip = [System.IO.Compression.ZipFile]::OpenRead($path)
Write-Host "glTF models in KayKit:"
$gltfs = $zip.Entries | Where-Object { $_.FullName -match "Assets/gltf/[^/]+\.gltf$" }
Write-Host "Total gltf in KayKit: $($gltfs.Count)"
$gltfs | Select-Object -First 40 | ForEach-Object { Write-Host "   $($_.Name)" }
$zip.Dispose()
