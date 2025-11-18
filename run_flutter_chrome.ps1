# Pfad zu deinem Flutter-Projekt
$projectPath = "C:\Programmierung\reflecto"

# Fester Port für Flutter-Web
$port = 7357

Write-Host "Starte Flutter Web-Server im Projektpfad: $projectPath" -ForegroundColor Cyan

# Flutter Web-Server in neuem PowerShell-Fenster starten
Start-Process powershell -ArgumentList @"
cd "$projectPath"
flutter run -d web-server --web-hostname=localhost --web-port=$port
"@ -WindowStyle Normal

# Kurz warten, bis der Server läuft
Start-Sleep -Seconds 8

# Chrome mit deinem Profil öffnen
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (-Not (Test-Path $chromePath)) {
    $chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

if (-Not (Test-Path $chromePath)) {
    Write-Host "Chrome wurde nicht gefunden. Bitte prüfe den Pfad in run_flutter_chrome.ps1." -ForegroundColor Red
    exit 1
}

Write-Host "Öffne Chrome mit Profil 'Default' auf http://localhost:$port" -ForegroundColor Green
& $chromePath --profile-directory="Default" "http://localhost:$port"

