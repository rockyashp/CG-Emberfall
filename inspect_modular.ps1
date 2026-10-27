Add-Type -AssemblyName System.IO.Compression.FileSystem

$path = "d:\Projects\yash_cg\Assets\Modular Character Outfits - Fantasy[Standard].zip"
$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($path)
Write-Host "Total entries in Modular Character: $($zipArchive.Entries.Count)"
$zipArchive.Entries | ForEach-Object {
    if ($_.FullName -notmatch "/$") {
        Write-Host "  $($_.FullName)"
    }
}
$zipArchive.Dispose()
