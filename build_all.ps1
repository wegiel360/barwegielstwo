$ErrorActionPreference = "Stop"
$flutter = "C:\tools\flutter\bin\flutter.bat"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$apps = @("bar_wegielstwo_order", "bar_wegielstwo_board", "bar_wegielstwo_admin", "bar_wegielstwo_pro")

Write-Host "=== BUILD ALL: Windows + Android + Installer ===" -ForegroundColor Cyan
Write-Host ""

# 1. Windows Release builds
Write-Host "--- STEP 1: Windows Release ---" -ForegroundColor Yellow
foreach ($app in $apps) {
    Write-Host "Building $app for Windows..." -ForegroundColor Gray
    Push-Location "$scriptDir\$app"
    & $flutter clean
    & $flutter pub get
    & $flutter build windows --release
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $app Windows" -ForegroundColor Red; exit 1 }
    Pop-Location
    Write-Host "OK: $app Windows" -ForegroundColor Green
}

# 2. Android APK builds
Write-Host "--- STEP 2: Android APK ---" -ForegroundColor Yellow
foreach ($app in $apps) {
    Write-Host "Building $app APK..." -ForegroundColor Gray
    Push-Location "$scriptDir\$app"
    & $flutter build apk --release
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $app APK" -ForegroundColor Red; exit 1 }
    Pop-Location
    Write-Host "OK: $app APK" -ForegroundColor Green
}

# 3. Inno Setup installer
Write-Host "--- STEP 3: Inno Setup Installer ---" -ForegroundColor Yellow
$iscc = "C:\Users\wegiel\AppData\Local\Programs\Inno Setup 7\ISCC.exe"
if (-not (Test-Path $iscc)) {
    $iscc = (Get-Command iscc -ErrorAction SilentlyContinue).Source
}
if ($iscc) {
    & $iscc "/DRootDir=$scriptDir" "$scriptDir\bar_wegielstwo_pro\installer\bar_wegielstwo_pro.iss"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Installer built successfully!" -ForegroundColor Green
    } else {
        Write-Host "Installer FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
    }
} else {
    Write-Host "Inno Setup not found - installer SKIPPED" -ForegroundColor Red
    Write-Host "Download: https://jrsoftware.org/isdownload.php" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Cyan
Write-Host "Windows EXEs: build\windows\x64\runner\Release\" -ForegroundColor White
Write-Host "Android APKs: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host "Installer: Created by Inno Setup (if available)" -ForegroundColor White
