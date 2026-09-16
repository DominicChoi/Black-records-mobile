$ErrorActionPreference = "Stop"
$project = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$project\project.godot")) { $project = $PSScriptRoot }
$apk = Join-Path $project "build\BlackRecords-v0.5.0-debug.apk"
if (-not (Test-Path $apk)) { throw "APK not found. Run 02_BUILD_APK.bat first." }

$sdkCandidates = @(
    $env:ANDROID_HOME,
    $env:ANDROID_SDK_ROOT,
    "$env:LOCALAPPDATA\Android\Sdk"
) | Where-Object { $_ -and (Test-Path $_) }

if ($sdkCandidates.Count -eq 0) { throw "Android SDK not found." }
$adb = Join-Path $sdkCandidates[0] "platform-tools\adb.exe"
if (-not (Test-Path $adb)) { throw "adb.exe not found." }

Write-Host "Connected devices:" -ForegroundColor Cyan
& $adb devices
Write-Host ""
Write-Host "Installing APK..." -ForegroundColor Cyan
& $adb install -r $apk
if ($LASTEXITCODE -ne 0) { throw "ADB install failed." }

Write-Host "[SUCCESS] Installed on phone." -ForegroundColor Green
Pause
