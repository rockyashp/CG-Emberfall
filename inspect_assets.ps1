Add-Type -AssemblyName System.IO.Compression.FileSystem

$zips = Get-ChildItem -Path "d:\Projects\yash_cg\Assets" -Filter "*.zip"

foreach ($z in $zips) {
    Write-Host "========================================="
    Write-Host "ZIP: $($z.Name) ($([math]::Round($z.Length / 1MB, 2)) MB)"
    Write-Host "========================================="
    $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($z.FullName)
    
    # Show summary of file extensions
    $exts = $zipArchive.Entries | Group-Object { [System.IO.Path]::GetExtension($_.FullName).ToLower() } | Select-Object Name, Count
    Write-Host "File Types:"
    foreach ($e in $exts) {
        Write-Host "  $($e.Name): $($e.Count)"
    }
    
    # Show some sample models/scenes/animations/licenses
    Write-Host "`nSample Models / Animations / Licenses:"
    $samples = $zipArchive.Entries | Where-Object { 
        $_.FullName -match "\.(gltf|glb|fbx|obj|dae|txt|md|license)$" -or $_.FullName -match "anim|character|monster|dungeon|weapon"
    } | Select-Object -First 30
    foreach ($s in $samples) {
        Write-Host "  $($s.FullName)"
    }
    $zipArchive.Dispose()
}
