$ErrorActionPreference = "Stop"
$root = "C:\Users\wegiel\Videos\BarWegielstwoFlutterDart"
$apps = @("bar_wegielstwo_order", "bar_wegielstwo_board", "bar_wegielstwo_admin", "bar_wegielstwo_pro")
$flutter = "C:\tools\flutter\bin\flutter.bat"

foreach ($app in $apps) {
    Write-Host "=== Building $app for Windows ===" -ForegroundColor Cyan
    Set-Location (Join-Path $root $app)
    & $flutter build windows --release 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $app" -ForegroundColor Red
        exit 1
    }
    Write-Host "SUCCESS: $app" -ForegroundColor Green
}

Write-Host "=== All Windows builds completed ===" -ForegroundColor Green