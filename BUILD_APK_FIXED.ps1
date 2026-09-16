$ErrorActionPreference = "Continue"

$project = $PSScriptRoot
if (-not (Test-Path "$project\project.godot")) {
    Write-Host "[ERROR] project.godot not found in:" -ForegroundColor Red
    Write-Host $project
    Pause
    exit 2
}

$godot = $null
$pathFile = Join-Path $project ".godot43_path.txt"

if (Test-Path $pathFile) {
    $saved = (Get-Content $pathFile -Raw).Trim().Trim('"')
    if ($saved -and (Test-Path $saved)) {
        $godot = $saved
    }
}

if (-not $godot) {
    $known = "E:\Develop Platform\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe"
    if (Test-Path $known) {
        $godot = $known
    }
}

if (-not $godot) {
    $typed = Read-Host "Godot 4.3 exe full path"
    $typed = $typed.Trim().Trim('"')
    if ($typed -and (Test-Path $typed)) {
        $godot = $typed
        Set-Content -Path $pathFile -Value $godot -Encoding UTF8
    }
}

if (-not $godot) {
    Write-Host "[ERROR] Godot executable not found." -ForegroundColor Red
    Pause
    exit 3
}

if (-not (Test-Path "$project\export_presets.cfg")) {
    Write-Host "[ERROR] export_presets.cfg not found." -ForegroundColor Red
    Write-Host "Copy v0.5.1 APK Test Pack export_presets.cfg into the project root."
    Pause
    exit 4
}

$buildDir = Join-Path $project "build"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$apk = Join-Path $buildDir "BlackRecords-v0.5.0-debug.apk"
$log = Join-Path $buildDir "android_export.log"

if (Test-Path $apk) {
    Remove-Item $apk -Force -ErrorAction SilentlyContinue
}

Write-Host "=== Black Records v0.5.0 Android Export ===" -ForegroundColor Cyan
Write-Host "Project : $project"
Write-Host "Godot   : $godot"
Write-Host "APK     : $apk"
Write-Host ""

# Parse/import has already been separately validated.
# Go directly to export and capture the REAL Android error, if any.
& $godot --headless --verbose --path $project --export-debug "Android" $apk 2>&1 |
    Tee-Object -FilePath $log

$exitCode = $LASTEXITCODE

Write-Host ""
if (($exitCode -eq 0) -and (Test-Path $apk)) {
    $item = Get-Item $apk
    Write-Host "[SUCCESS] APK created." -ForegroundColor Green
    Write-Host $item.FullName -ForegroundColor Green
    Write-Host ("Size: {0:N1} MB" -f ($item.Length / 1MB))
    Write-Host ""
    Write-Host "Next: connect Galaxy Z Fold 7 with USB debugging and run 03_INSTALL_TO_PHONE.bat." -ForegroundColor Cyan
    Pause
    exit 0
}

Write-Host "[FAIL] Android export failed." -ForegroundColor Red
Write-Host ""
Write-Host "=== Important export lines ===" -ForegroundColor Cyan

$lines = Get-Content $log -ErrorAction SilentlyContinue
$interesting = $lines | Where-Object {
    $_ -match "ERROR:|Error:|FAILED|failed|template|Android|SDK|JDK|Java|keystore|export|Could not|not found|missing"
}

if ($interesting.Count -gt 0) {
    $interesting | Select-Object -Last 100 | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }
} else {
    $lines | Select-Object -Last 120
}

Write-Host ""
Write-Host "Send me a screenshot of the lines above." -ForegroundColor Yellow
Write-Host "Full log: $log" -ForegroundColor Yellow
Pause
exit 1
