Add-Type -AssemblyName System.IO.Compression.FileSystem

$zips = Get-ChildItem -Path "d:\Projects\yash_cg\Assets" -Filter "*.zip"

foreach ($z in $zips) {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($z.FullName)
    $licenses = $zip.Entries | Where-Object { $_.Name -match "license|readme" }
    foreach ($lic in $licenses) {
        Write-Host "================================"
        Write-Host "[$($z.Name)] -> $($lic.FullName)"
        Write-Host "================================"
        $reader = New-Object System.IO.StreamReader($lic.Open())
        $text = $reader.ReadToEnd()
        $reader.Dispose()
        Write-Host $text
    }
    $zip.Dispose()
}
