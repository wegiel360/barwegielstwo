$ErrorActionPreference = "Stop"
$flutter = "C:\tools\flutter\bin\flutter.bat"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== BUILD ALL ===" -ForegroundColor Cyan
Write-Host ""

# 1. Windows Release (only board)
Write-Host "--- STEP 1: Windows Release (Board only) ---" -ForegroundColor Yellow
Push-Location "$scriptDir\bar_wegielstwo_board"
& $flutter clean
& $flutter pub get
& $flutter build windows --release
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: board Windows" -ForegroundColor Red; exit 1 }
Pop-Location
Write-Host "OK: board Windows" -ForegroundColor Green

# 2. Inno Setup installer (board)
Write-Host "--- STEP 2: Inno Setup Installer ---" -ForegroundColor Yellow
$iscc = "C:\Users\wegiel\AppData\Local\Programs\Inno Setup 7\ISCC.exe"
if (-not (Test-Path $iscc)) {
    $iscc = (Get-Command iscc -ErrorAction SilentlyContinue).Source
}
if ($iscc) {
    & $iscc "/DRootDir=$scriptDir" "$scriptDir\installer\bar_wegielstwo.iss"
    if ($LASTEXITCODE -eq 0) { Write-Host "Installer OK" -ForegroundColor Green }
    else { Write-Host "Installer FAILED (exit $LASTEXITCODE)" -ForegroundColor Red }
} else {
    Write-Host "Inno Setup not found - SKIPPED" -ForegroundColor Red
}

# 3. Copy to releases/
Write-Host "--- STEP 3: Copy to releases/ ---" -ForegroundColor Yellow
$rel = "$scriptDir\releases"
New-Item -ItemType Directory -Path "$rel\windows" -Force | Out-Null
Copy-Item "$scriptDir\bar_wegielstwo_board\build\windows\x64\runner\Release\bar_wegielstwo_board.exe" "$rel\windows\" -Force
if (Test-Path "$scriptDir\installer\Output\BarWegielstwo-Board-Setup-v0.0.2-alpha.exe") {
    Copy-Item "$scriptDir\installer\Output\BarWegielstwo-Board-Setup-v0.0.2-alpha.exe" "$rel\windows\" -Force
}
Write-Host "OK: releases/" -ForegroundColor Green

Write-Host ""
Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Cyan
Write-Host "Windows EXE: releases\windows\bar_wegielstwo_board.exe" -ForegroundColor White
Write-Host "Installer: releases\windows\BarWegielstwo-Board-Setup-v0.0.2-alpha.exe" -ForegroundColor White
