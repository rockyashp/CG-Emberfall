Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead("d:\Projects\yash_cg\Assets\KayKit_Dungeon_Pack_1.1_FREE.zip")
Write-Host "Textures / Materials in KayKit:"
$zip.Entries | Where-Object { $_.FullName -match "texture|png" } | ForEach-Object {
    Write-Host "   $($_.FullName)"
}
$zip.Dispose()
