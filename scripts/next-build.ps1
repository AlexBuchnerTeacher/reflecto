param(
  [Parameter(Position=0)] [ValidateSet('apk','ipa')] [string] $Target = 'apk',
  [Parameter()] [string] $Channel = 'local',
  [Parameter()] [string] $Version,
  [switch] $NoTime
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Resolve-Path (Join-Path $root '..'))

$counterFile = '.build_number'
if (-not (Test-Path $counterFile)) { '0' | Out-File -Encoding ascii $counterFile }
$current = [int](Get-Content $counterFile).Trim()
$next = $current + 1
$next.ToString() | Out-File -Encoding ascii $counterFile
Write-Host "Next build number: $next"

# Version aus pubspec.yaml lesen, falls nicht übergeben
if (-not $Version) {
  $line = (Select-String -Path 'pubspec.yaml' -Pattern '^version:\s*(.+)$').Matches.Value
  if ($line) {
    $Version = ($line -split ':' ,2)[1].Trim()
    # nur SemVer ohne Build-Anteil nehmen (vor '+')
    if ($Version -match '^([^+]+)\+') { $Version = $Matches[1].Trim() }
  } else {
    $Version = '0.0.0'
  }
}

$sha = (git rev-parse --short HEAD) 2>$null
if (-not $sha) { $sha = 'dev' }

$defines = @("--dart-define=BUILD_CHANNEL=$Channel","--dart-define=GIT_SHA=$sha","--dart-define=BUILD_NUMBER=$next")
if (-not $NoTime) {
  $time = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
  $defines += "--dart-define=BUILD_TIME=$time"
}

if ($Target -eq 'apk') {
  flutter build apk --release --build-name $Version --build-number $next @defines
} elseif ($Target -eq 'ipa') {
  flutter build ipa --release --build-name $Version --build-number $next @defines
}

Write-Host "Done. Version=$Version BuildNumber=$next Channel=$Channel SHA=$sha"

