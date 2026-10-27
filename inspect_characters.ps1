Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip1 = [System.IO.Compression.ZipFile]::OpenRead("d:\Projects\yash_cg\Assets\Ultimate Animated Character Pack - Nov 2019-20261026T204646Z-1-001.zip")
Write-Host "Characters in Ultimate Animated Character Pack:"
$zip1.Entries | Where-Object { $_.FullName -match "glTF/[^/]+\.gltf$" } | ForEach-Object {
    Write-Host "   $($_.Name)"
}
$zip1.Dispose()
