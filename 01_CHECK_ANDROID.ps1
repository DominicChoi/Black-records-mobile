$ErrorActionPreference = "Continue"
Write-Host "=== Black Records Android Environment Check ===" -ForegroundColor Cyan

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

$godot = Find-Godot
if ($godot) {
    Write-Host "[OK] Godot: $godot" -ForegroundColor Green
    & $godot --version
} else {
    Write-Host "[NG] Godot 4.3 executable not found automatically." -ForegroundColor Red
}

$java = Get-Command java -ErrorAction SilentlyContinue
if ($java) {
    Write-Host "[OK] Java: $($java.Source)" -ForegroundColor Green
    java -version
} else {
    Write-Host "[NG] Java not found in PATH." -ForegroundColor Red
}

$sdkCandidates = @(
    $env:ANDROID_HOME,
    $env:ANDROID_SDK_ROOT,
    "$env:LOCALAPPDATA\Android\Sdk"
) | Where-Object { $_ -and (Test-Path $_) }

if ($sdkCandidates.Count -gt 0) {
    $sdk = $sdkCandidates[0]
    Write-Host "[OK] Android SDK: $sdk" -ForegroundColor Green
    if (Test-Path "$sdk\platform-tools\adb.exe") {
        Write-Host "[OK] adb found" -ForegroundColor Green
        & "$sdk\platform-tools\adb.exe" devices
    } else {
        Write-Host "[NG] adb.exe not found" -ForegroundColor Red
    }
    if (Test-Path "$sdk\build-tools\34.0.0") {
        Write-Host "[OK] Build Tools 34.0.0" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Build Tools 34.0.0 not found" -ForegroundColor Yellow
    }
    if (Test-Path "$sdk\platforms\android-34") {
        Write-Host "[OK] Android Platform 34" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Android Platform 34 not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "[NG] Android SDK folder not found." -ForegroundColor Red
}

Write-Host ""
Write-Host "If every major item is OK, run 02_BUILD_APK.bat." -ForegroundColor Cyan
Pause
