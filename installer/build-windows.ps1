# Builds WinDjView-UA on Windows: WinDjView.exe + WinDjViewUA.dll (x64 and Win32) and the NSIS installer.
# Needs: Visual Studio 2026 with "Desktop development with C++" and "C++ MFC", NSIS 3.x.
# Result: installer\dist\WinDjView-UA-<version>-Setup.exe and SHA256SUMS.txt
#   powershell -ExecutionPolicy Bypass -File installer\build-windows.ps1
$ErrorActionPreference = 'Stop'
$inst = $PSScriptRoot
$repo = Split-Path -Parent $inst
$sln  = Join-Path $repo 'windjview\WinDjView.15.sln'

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.ATLMFC -property installationPath
if (-not $vs) { throw 'Visual Studio with C++ MFC was not found' }
$msbuild = Join-Path $vs 'MSBuild\Current\Bin\MSBuild.exe'
# the projects use the VS 2026 toolset (v145); Visual Studio 2022 (e.g. GitHub runners) builds them with v143
$vsMajor = [int](& $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.ATLMFC -property installationVersion).Split('.')[0]
$toolset = @()
if ($vsMajor -lt 18) { $toolset = @('/p:PlatformToolset=v143') }

$makensis = (Get-Command makensis -ErrorAction SilentlyContinue).Source
if (-not $makensis) { $makensis = Join-Path ${env:ProgramFiles(x86)} 'NSIS\makensis.exe' }
if (-not (Test-Path $makensis)) { throw 'NSIS (makensis) was not found' }

# the version is taken from the program resources, so the installer always matches the build
$rc = Get-Content (Join-Path $repo 'windjview\WinDjView.rc') -Raw
if ($rc -notmatch 'IDS_CURRENT_VERSION\s+"([0-9.]+)"') { throw 'IDS_CURRENT_VERSION not found' }
$version = $Matches[1]
Write-Host "WinDjView-UA $version"

foreach ($platform in 'x64', 'Win32') {
    & $msbuild $sln /t:WinDjView_15:Rebuild /p:Configuration=Release /p:Platform=$platform @toolset /m /v:m /nologo
    if ($LASTEXITCODE -ne 0) { throw "MSBuild $platform failed" }
}

$dist = Join-Path $inst 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
Push-Location $inst
try {
    & $makensis /V2 "/DAPP_VERSION=$version" WinDjView-Setup.nsi
    if ($LASTEXITCODE -ne 0) { throw 'makensis failed' }
    Move-Item -Force "WinDjView-UA-$version-Setup.exe" $dist
} finally { Pop-Location }

Push-Location $dist
try {
    # LF line endings, so that `sha256sum -c SHA256SUMS.txt` works on Linux and in Git Bash
    $sums = Get-ChildItem *.exe | ForEach-Object { '{0}  {1}' -f (Get-FileHash $_.Name -Algorithm SHA256).Hash.ToLower(), $_.Name }
    [IO.File]::WriteAllText((Join-Path $dist 'SHA256SUMS.txt'), (($sums -join "`n") + "`n"))
    Get-Content SHA256SUMS.txt
} finally { Pop-Location }
