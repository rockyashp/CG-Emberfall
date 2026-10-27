$scnPath = "d:\Projects\yash_cg\.godot\imported\Knight_Male.gltf-fa1469f91a010e30c2703aa4d3aa53df.scn"
$bytes = [System.IO.File]::ReadAllBytes($scnPath)
$text = [System.Text.Encoding]::ASCII.GetString($bytes)
$matches = [regex]::Matches($text, '[A-Za-z0-9_]{3,30}')
$animNames = @()
foreach ($m in $matches) {
    if ($m.Value -match "Idle|Run|Walk|Slash|Punch|Hit|Death|Roll|Jump|Victory") {
        $animNames += $m.Value
    }
}
$animNames | Select-Object -Unique | ForEach-Object { Write-Host "Anim name in scn: $_" }
