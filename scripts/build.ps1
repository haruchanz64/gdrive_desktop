param(
    [string]$Version = "1.0.0",
    [string]$Platform = "windows",
    [switch]$Clean
)

$AppName = "GDrive Desktop"
$DistDir = "dist"

$PlatformOutputMap = @{
    "windows" = "build\windows\x64\runner\Release"
    "linux"   = "build\linux\x64\release\bundle"
    "macos"   = "build\macos\Build\Products\Release"
}

Write-Host ""
Write-Host "Building $AppName v$Version for $Platform" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor DarkGray

# ── Validate Platform ─────────────────────────────────────────────────────────
if (-not $PlatformOutputMap.ContainsKey($Platform)) {
    Write-Host "Unknown platform '$Platform'. Valid: windows, linux, macos" -ForegroundColor Red
    exit 1
}

# ── Clean ─────────────────────────────────────────────────────────────────────
if ($Clean) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    flutter clean
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

# ── Dependencies ──────────────────────────────────────────────────────────────
Write-Host "Fetching dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "flutter pub get failed." -ForegroundColor Red
    exit 1
}

# ── Build ─────────────────────────────────────────────────────────────────────
Write-Host "Building for $Platform..." -ForegroundColor Yellow
flutter build $Platform --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed." -ForegroundColor Red
    exit 1
}

# ── Package ───────────────────────────────────────────────────────────────────
Write-Host "Packaging output..." -ForegroundColor Yellow

if (Test-Path $DistDir) {
    Remove-Item $DistDir -Recurse -Force
}
New-Item -ItemType Directory -Path $DistDir | Out-Null

$OutputDir = $PlatformOutputMap[$Platform]
$ZipName   = "gdrive_desktop_v${Version}_${Platform}.zip"

Compress-Archive -Path "$OutputDir\*" -DestinationPath "$DistDir\$ZipName"

Write-Host ""
Write-Host "======================================" -ForegroundColor DarkGray
Write-Host "Build complete." -ForegroundColor Green
Write-Host "Output : $OutputDir"      -ForegroundColor Gray
Write-Host "Archive: $DistDir\$ZipName" -ForegroundColor Gray
Write-Host ""