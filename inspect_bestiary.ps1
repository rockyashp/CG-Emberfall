Add-Type -AssemblyName System.IO.Compression.FileSystem

$path = "d:\Projects\yash_cg\Assets\Bestiary - Dungeon Monsters Kit[Standard].zip"
$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($path)
Write-Host "Total entries in Bestiary: $($zipArchive.Entries.Count)"
$zipArchive.Entries | ForEach-Object {
    if ($_.FullName -notmatch "/$") {
        Write-Host "  $($_.FullName)"
    }
}
$zipArchive.Dispose()
