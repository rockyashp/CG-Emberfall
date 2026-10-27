Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipPath = "d:\Projects\yash_cg\Assets\Bestiary - Dungeon Monsters Kit[Standard].zip"
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)

function Inspect-Glb($entryName) {
    $entry = $zip.GetEntry($entryName)
    if ($entry) {
        $stream = $entry.Open()
        $br = New-Object System.IO.BinaryReader($stream)
        # GLB header: magic (4), version (4), length (4)
        $magic = $br.ReadUInt32()
        $version = $br.ReadUInt32()
        $length = $br.ReadUInt32()
        
        # Chunk 0: chunkLength (4), chunkType (4)
        $chunkLength = $br.ReadUInt32()
        $chunkType = $br.ReadUInt32() # 0x4E4F534A is JSON
        
        $jsonBytes = $br.ReadBytes($chunkLength)
        $jsonStr = [System.Text.Encoding]::UTF8.GetString($jsonBytes)
        
        Write-Host "=== $entryName ==="
        $json = ConvertFrom-Json $jsonStr
        if ($json.animations) {
            Write-Host "Animations ($($json.animations.Count)):"
            foreach ($anim in $json.animations) {
                Write-Host "   $($anim.name)"
            }
        } else {
            Write-Host "No embedded animations!"
        }
        
        if ($json.nodes) {
            Write-Host "Sample Bones/Nodes ($($json.nodes.Count)):"
            $json.nodes | Select-Object -First 20 | ForEach-Object { Write-Host "   $($_.name)" }
        }
        $stream.Dispose()
    }
}

Inspect-Glb("Bestiary - Dungeon Monsters Kit[Standard]/Exports/GLB (Godot-Unreal)/Imp.glb")
Inspect-Glb("Bestiary - Dungeon Monsters Kit[Standard]/Exports/GLB (Godot-Unreal)/Puglin.glb")

$zip.Dispose()
