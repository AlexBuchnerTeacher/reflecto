# Buchner Styleguide (Reflecto)

Kurzer Überblick über die Design‑Tokens und Leitlinien. Ziel: konsistente, lesbare UI mit ruhigem Blau‑Akzent, klarer Typografie und dezenten Interaktionen.

## Tokens

- Farben (ColorScheme‑Erweiterung via `ReflectoSchemeX`)
  - `surfaceCard`: neutrale Kartenfläche
  - `surfaceContainerSoft`: sehr dezente Containerfläche
  - `borderSubtle`: zurückhaltende Rahmenfarbe

- Abstände (`ReflectoSpacing`)
  - s4, s8, s12, s16, s24 (px)

- Radien (`ReflectoRadii`)
  - input: 12
  - button: 14
  - card: 16

- Breakpoints (`ReflectoBreakpoints`)
  - contentMax: 820 px

- Bewegung (`ReflectoMotion`)
  - fast 150 ms, normal 200 ms, slow 300 ms

## Typografie

- Titel: Lexend (fett), Hierarchien über Theme (`titleLarge`/`titleMedium`)
- Fließtext: Inter (16/15/13), erhöhte Zeilenhöhe
- Einheitliche Textfarben je Mode aus dem Theme
 - Keine Inline-`TextStyle` für Größe/Gewicht, wenn eine passende Style im Theme existiert.

## Farben

- Seed‑Farbe ruhiges Blau; Ableitung via Material 3 ColorScheme
- Statusfarben dezent; Rahmen über `outlineVariant` bzw. `borderSubtle`

## Komponenten

- Cards: sanfte Schatten, `surfaceCard`, Border `borderSubtle`, Radius 16
- Buttons: Primär auf Blau, Radius 14, 48 px min‑Höhe
- Inputs: filled, 12/12 Padding, Outline 1.2 px, Radius 12

## Icons

- Stufe 1: Emoji für Emotionen (sparsam, Titel/Highlight)
- Stufe 2: Material Symbols Rounded für UI‑Aktionen
- Stufe 3: Custom Icon (Branding) später optional

## Interaktionen

- Hover (Web/Desktop): leichte Schatten-/Farbverstärkung (200 ms)
- Tap‑Feedback (Mobile): standardmäßige Ink‑Reaktion, klare Kontraste
- Sync/Status: dezente Badges/Chips, kein aggressives Blinken

## Layout & Responsiveness

- Contentbreite max. 820 px (Center + ConstrainedBox)
- Spacing‑Stufen 4/8/12/16/24 über `ReflectoSpacing` Tokens nutzen (`s4/s8/s12/s16/s24`).
- Keine harten Hex‑Farben/Abstände in Widgets — statt dessen Tokens/Theme verwenden.

