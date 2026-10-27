Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead("d:\Projects\yash_cg\Assets\Ultimate Animated Character Pack - Nov 2019-20261026T204646Z-1-001.zip")
Write-Host "Files in glTF folder of Ultimate Pack:"
$zip.Entries | Where-Object { $_.FullName -match "glTF/" } | Select-Object -First 30 | ForEach-Object {
    Write-Host "   $($_.FullName)"
}
$zip.Dispose()
