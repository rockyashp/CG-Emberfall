Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead("d:\Projects\yash_cg\Assets\Medieval Weapons Pack by @Quaternius-20261026T204920Z-1-001.zip")
Write-Host "Textures / Materials in Weapons Pack:"
$zip.Entries | Where-Object { $_.FullName -match "png|mtl" } | Select-Object -First 20 | ForEach-Object {
    Write-Host "   $($_.FullName)"
}
$zip.Dispose()
