Add-Type -AssemblyName System.IO.Compression.FileSystem

$bytes = [System.IO.File]::ReadAllBytes("d:\Projects\yash_cg\assets\enemies\Imp.glb")
Write-Host "Imp.glb size: $($bytes.Length) bytes"
$stream = [System.IO.File]::OpenRead("d:\Projects\yash_cg\assets\enemies\Imp.glb")
$br = New-Object System.IO.BinaryReader($stream)
$magic = $br.ReadUInt32()
$version = $br.ReadUInt32()
$length = $br.ReadUInt32()
$chunkLen = $br.ReadUInt32()
$chunkType = $br.ReadUInt32()
$jsonBytes = $br.ReadBytes($chunkLen)
$json = ConvertFrom-Json ([System.Text.Encoding]::UTF8.GetString($jsonBytes))
$stream.Dispose()

$positions = $json.accessors | Where-Object { $_.type -eq "VEC3" -and $_.min -and $_.max }
foreach ($p in $positions) {
    Write-Host "Bound Min: ($($p.min -join ', ')) | Max: ($($p.max -join ', '))"
}
