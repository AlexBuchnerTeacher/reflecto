# Changelog

Alle nennenswerten Änderungen an Reflecto. Siehe Releases für automatisch generierte Notes.

## Unreleased

–

## v1.2.0

- UI/Tagesansicht
  - Deutsches Datumsformat (AppBar) mit `intl` + Locale-Init (de_DE)
  - Kalender-Bottom-Sheet zur Datumsauswahl
  - 7-Tage-Leiste (ChoiceChips) + Swipe-Navigation (±1 Tag)
  - Heutiger Tag hervorgehoben (Punkt/Umrandung)
  - Streak-Kontextzeile „🔥 X Tage in Folge“
- Settings
  - Unbenutzte Sign-Out-Methode/Import entfernt
- Build
  - Version/Build-Quelle vereinheitlicht (Fix #16)

## v1.1.0

- Einstellungen
  - Theme-Umschaltung: System/Hell/Dunkel, sofort wirksam, persistent
  - Profil bearbeiten: Anzeigename ändern (FirebaseAuth + Firestore), createdAt bleibt erhalten
  - Versionsanzeige im Einstellungen-Reiter
- UI/Lesbarkeit
  - Status- und Fortschritts-Chips auf ColorScheme umgestellt (guter Kontrast in Hell/Dunkel)
  - Emoji-Ratings mit Theme-Farben und klarer Textfarbe
- CI/Automation
  - Flutter CI (Format/Analyze/Test, Web-Build-Artefakt)
  - GitHub Pages: Deploy nur auf `main`, PWA/SW deaktiviert (verhindert White-Screen)
  - PR-Qualität: Semantic PR Check, Auto-Labels, PR-Templates
  - Dependabot: Auto-Merge für Minor/Patch, Riverpod-Major ignoriert
  - Auto-PR bei Push auf `feat/*`, `fix/*`, etc. (fehlertolerant)
  - Seed-Workflows: Labels, Milestones
- Doku/Repo
  - Architektur-Überblick, Maintainer-Guide, Security Policy
  - CODEOWNERS, Dependabot-Konfiguration
- Tests/Fixes
  - Widget-Smoketest unabhängig von Firebase
  - Analyzer-Warnungen/Deprecations bereinigt

Vollständige Release-Notes: https://github.com/AlexBuchnerTeacher/reflecto/releases/tag/v1.1.0
