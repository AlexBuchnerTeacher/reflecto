# Changelog

Alle nennenswerten Änderungen an Reflecto. Siehe Releases für automatisch generierte Notes.

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
