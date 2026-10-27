$content = Get-Content 'd:\Projects\yash_cg\assets\characters\Knight_Male.gltf' -Raw
$json = $content | ConvertFrom-Json
$fistR = $json.nodes | Where-Object { $_.name -eq 'Fist.R' }
Write-Host "Fist.R node:" ($fistR | ConvertTo-Json -Depth 3)
