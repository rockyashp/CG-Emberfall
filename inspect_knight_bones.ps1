$path = "d:\Projects\yash_cg\assets\characters\Knight_Male.gltf"
$content = Get-Content $path -Raw
$json = ConvertFrom-Json $content
$nodes = $json.nodes
for ($i=0; $i -lt $nodes.Count; $i++) {
    if ($nodes[$i].name -match "Fist|Hand") {
        Write-Host ("Node " + $i + ": " + $nodes[$i].name)
        Write-Host ("  Translation: " + ($nodes[$i].translation -join ', '))
        Write-Host ("  Rotation: " + ($nodes[$i].rotation -join ', '))
        Write-Host ("  Scale: " + ($nodes[$i].scale -join ', '))
    }
}
