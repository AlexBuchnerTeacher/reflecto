# Mobile Builds: Version und Buildnummer (Issue #16)

Ziel: Einheitliche Quelle und Anzeige für Version und Buildnummer.

- Version: aus `pubspec.yaml: version` (SemVer, z. B. `1.2.3+45`)
- Settings zeigt:
  - Version: `PackageInfo.version` (SemVer, ohne Build-Anteil)
  - Build: `<buildNumber> <channel> <sha> <time>`

Beim mobilen Build (lokal/CI) bitte IMMER Name/Nummer setzen:

## Android

```
flutter build apk --release \
  --build-name $VERSION \
  --build-number $BUILD_NUMBER \
  --dart-define=BUILD_CHANNEL=$BUILD_CHANNEL \
  --dart-define=GIT_SHA=$GIT_SHA \
  --dart-define=BUILD_TIME=$BUILD_TIME
```

## iOS (Signatur/Provisioning erforderlich)

```
flutter build ipa --release \
  --build-name $VERSION \
  --build-number $BUILD_NUMBER \
  --dart-define=BUILD_CHANNEL=$BUILD_CHANNEL \
  --dart-define=GIT_SHA=$GIT_SHA \
  --dart-define=BUILD_TIME=$BUILD_TIME
```

Hinweise:

- `BUILD_CHANNEL` z. B. `dev`, `main`, `beta` (Default lokal: `local`).
- `GIT_SHA` bevorzugt der Commit SHA, `BUILD_TIME` ISO-Zeitstempel (z. B. CI-Startzeit).
- Web-Build (Pages) setzt die `--dart-define` bereits im Workflow (`gh-pages.yml`).

### Beispiel (lokal, PowerShell)

```
$Env:VERSION = '1.0.1'
$Env:BUILD_NUMBER = '12'
$Env:BUILD_CHANNEL = 'dev'
$Env:GIT_SHA = (git rev-parse HEAD)
$Env:BUILD_TIME = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
flutter build apk --release `
  --build-name $Env:VERSION `
  --build-number $Env:BUILD_NUMBER `
  --dart-define=BUILD_CHANNEL=$Env:BUILD_CHANNEL `
  --dart-define=GIT_SHA=$Env:GIT_SHA `
  --dart-define=BUILD_TIME=$Env:BUILD_TIME
```

### Validierung

- `flutter analyze` sauber
- App starten: Einstellungen zeigt `Version = info.version` und `Build = buildNumber channel sha time`

