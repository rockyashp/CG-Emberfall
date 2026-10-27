$scnPath = "d:\Projects\yash_cg\.godot\imported\Knight_Male.gltf-fa1469f91a010e30c2703aa4d3aa53df.scn"
$bytes = [System.IO.File]::ReadAllBytes($scnPath)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$animList = @("Idle", "Run", "Walk", "SwordSlash", "Punch", "RecieveHit", "Death", "Roll", "Jump", "Victory")
foreach ($a in $animList) {
    if ($text.Contains($a)) {
        Write-Host "Found animation in scn: $a"
    }
}
