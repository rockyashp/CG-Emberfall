$content = Get-Content 'd:\Projects\yash_cg\assets\characters\Knight_Male.gltf' -Raw
$json = $content | ConvertFrom-Json
Write-Host "Total nodes: $($json.nodes.Count)"
foreach ($n in $json.nodes) {
    if ($n.name -match 'Fist|Hand|Arm|Right|weapon|Hold') {
        Write-Host "Node: $($n.name)"
    }
}
