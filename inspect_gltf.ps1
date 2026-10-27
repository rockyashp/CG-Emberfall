Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipPath = "d:\Projects\yash_cg\Assets\Ultimate Animated Character Pack - Nov 2019-20261026T204646Z-1-001.zip"
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$entry = $zip.GetEntry("Ultimate Animated Character Pack - Nov 2019/glTF/Knight_Male.gltf")
if ($entry) {
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $content = $reader.ReadToEnd()
    $reader.Dispose()
    
    Write-Host "Knight_Male.gltf size: $($content.Length) bytes"
    $json = ConvertFrom-Json $content
    if ($json.animations) {
        Write-Host "Animations in Knight_Male ($($json.animations.Count)):"
        foreach ($anim in $json.animations) {
            Write-Host "   Animation: $($anim.name)"
        }
    } else {
        Write-Host "No embedded animations in Knight_Male.gltf"
    }
    
    if ($json.nodes) {
        Write-Host "Nodes/Bones count: $($json.nodes.Count)"
        $json.nodes | Select-Object -First 25 | ForEach-Object { Write-Host "   Node: $($_.name)" }
    }
}
$zip.Dispose()
