$ErrorActionPreference = "Stop"

function Find-Godot {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command godot4 -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        "$PSScriptRoot\Godot_v4.3-stable_win64.exe",
        "$PSScriptRoot\Godot.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.3-stable_win64.exe",
        "$env:USERPROFILE\Desktop\Godot_v4.3-stable_win64.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$project = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$project\project.godot")) {
    $project = $PSScriptRoot
}
if (-not (Test-Path "$project\project.godot")) {
    throw "project.godot not found. Put this APK test pack inside the project root or run the script from the project root."
}

$godot = Find-Godot
if (-not $godot) {
    $typed = Read-Host "Godot 4.3 exe full path"
    if ($typed -and (Test-Path $typed)) {
        $godot = $typed
    } else {
        throw "Godot executable not found."
    }
}

$buildDir = Join-Path $project "build"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$apk = Join-Path $buildDir "BlackRecords-v0.5.0-debug.apk"

Write-Host "=== Import/parse check ===" -ForegroundColor Cyan
& $godot --headless --path $project --editor --quit
if ($LASTEXITCODE -ne 0) {
    throw "Godot import/parse check failed. Open Godot and send the first red error screenshot."
}

Write-Host "=== Android Debug APK export ===" -ForegroundColor Cyan
& $godot --headless --path $project --export-debug "Android" $apk
if ($LASTEXITCODE -ne 0) {
    throw "APK export failed. Open Godot > Project > Export and verify Android SDK/JDK/export templates."
}

if (-not (Test-Path $apk)) {
    throw "Export command finished but APK was not found: $apk"
}

$item = Get-Item $apk
Write-Host ""
Write-Host "[SUCCESS] APK created" -ForegroundColor Green
Write-Host $item.FullName -ForegroundColor Green
Write-Host ("Size: {0:N1} MB" -f ($item.Length / 1MB))
Write-Host ""
Write-Host "Connect Galaxy with USB debugging, then use Godot one-click deploy or run INSTALL_TO_PHONE.bat."
Pause
