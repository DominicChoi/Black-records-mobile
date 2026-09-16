$ErrorActionPreference = "Continue"

$project = $PSScriptRoot
if (-not (Test-Path "$project\project.godot")) {
    Write-Host "[ERROR] project.godot not found in:" -ForegroundColor Red
    Write-Host $project
    Write-Host "Copy this file into the Black-records-mobile project root and run again."
    Pause
    exit 2
}

$pathFile = Join-Path $project ".godot43_path.txt"
$godot = $null

if (Test-Path $pathFile) {
    $saved = (Get-Content $pathFile -Raw).Trim().Trim('"')
    if ($saved -and (Test-Path $saved)) {
        $godot = $saved
    }
}

if (-not $godot) {
    $candidates = @(
        "E:\Develop Platform\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.3-stable_win64.exe",
        "$env:USERPROFILE\Desktop\Godot_v4.3-stable_win64.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) {
            $godot = $p
            break
        }
    }
}

if (-not $godot) {
    $typed = Read-Host "Godot 4.3 exe full path"
    $typed = $typed.Trim().Trim('"')
    if ($typed -and (Test-Path $typed)) {
        $godot = $typed
    }
}

if (-not $godot) {
    Write-Host "[ERROR] Godot executable not found." -ForegroundColor Red
    Pause
    exit 3
}

Set-Content -Path $pathFile -Value $godot -Encoding UTF8

$buildDir = Join-Path $project "build"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$log = Join-Path $buildDir "godot_parse_diagnostic.log"

Write-Host ""
Write-Host "=== Godot 4.3 parse diagnostic ===" -ForegroundColor Cyan
Write-Host "Project: $project"
Write-Host "Godot  : $godot"
Write-Host "Log    : $log"
Write-Host ""

& $godot --headless --verbose --path $project --editor --quit 2>&1 |
    Tee-Object -FilePath $log

$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "=== Last diagnostic lines ===" -ForegroundColor Cyan
$lines = Get-Content $log
$interesting = $lines | Where-Object {
    $_ -match "SCRIPT ERROR|Parse Error|ERROR:|Error at|res://|Invalid"
}

if ($interesting.Count -gt 0) {
    $interesting | Select-Object -First 80 | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }
} else {
    $lines | Select-Object -Last 80
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "[PASS] Godot parse/import check completed." -ForegroundColor Green
    Write-Host "Next: run the APK build script." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Parse/import error detected." -ForegroundColor Red
    Write-Host "Please send a screenshot of the red lines above, or send this file:" -ForegroundColor Yellow
    Write-Host $log -ForegroundColor Yellow
}

Write-Host ""
Pause
