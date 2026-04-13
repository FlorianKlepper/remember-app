# ActivityTracker2 — CLAUDE.md
# Projektbriefing für Claude Code · Bitte bei jeder Session vollständig lesen
# Version 2 — nach Finetuning-Review

---

## 1. App-Identität

- **Codename:** ActivityTracker2
- **App-Name (App Store):** **Remember** (primär) — "Trace" als Alternative noch offen
- **Design-Referenz:** modern, schlicht — Orientierung an "Day One" App (kein verspieltes UI)
- **Zweck:** Modernes Tagebuch 2.0 — Erlebnisse auf der Karte, in Aktivitäten und auf einer Zeitachse
- **Kernaussage:** "Dein Leben als Karte & Tagebuch" / "Remember your life, your places, your activities"
- **Zielgruppe:** iOS-Nutzer, 25–55 Jahre, journal-affin, privacy-sensibel, nicht social-media-getrieben
- **Was die App NICHT ist:** kein Komoot-Klon, kein Strava, kein Day-One-Klon, kein Therapie-Tool

---

## 2. Tech-Stack (nicht verhandelbar)

- **Plattform:** iOS 17+ — kein iOS 16, kein macOS Catalyst im MVP
- **Sprache:** Swift 5.9+
- **UI-Framework:** SwiftUI — kein UIKit ausser wo unvermeidbar (z.B. UIImpactFeedbackGenerator)
- **Persistenz:** SwiftData — kein CoreData, kein UserDefaults fuer Activity/Location-Daten
- **Karten:** MapKit (Apple Maps) — kein Google Maps, kein Mapbox
- **Monetarisierung:** StoreKit 2 — kein RevenueCat
- **Analytics:** Apple App Analytics — vorbereitet fuer Firebase/Amplitude, kein SDK im MVP
- **Kein Backend im MVP:** keine REST-API, kein Firestore, kein Supabase
- **Kein iCloud Sync im MVP:** lokale Speicherung only
- **Lokalisierung:** Deutsch + Englisch — **beide Sprachen von Anfang an vollständig implementiert**. Alle UI-Strings via `LocalizedStringKey`, alle Texte in `Localizable.xcstrings` (String Catalog). Keine hardcodierten Strings im Swift-Code — weder deutsch noch englisch.

---

## 3. Architektur — MVVM (non-negotiable)

- **Pattern:** MVVM — Model / ViewModel / View
- **Observable:** `@Observable` Makro (iOS 17+) — NIEMALS `ObservableObject` / `@Published`
- **SwiftData Context:** immer via `@Environment(\.modelContext)` — nie direkt instanziieren
- **Environment Injection:** alle Manager + ViewModels in `ActivityTracker2App.swift` per `.environment()` — keine `.shared` Singletons ausser AnalyticsManager und HapticManager
- **Navigation:** NavigationStack — kein NavigationView (deprecated)
- **Sheets:** `.sheet()` / `.fullScreenCover()` — keine custom Modal-Implementierungen

### Code-Pflichtregeln
- Kein force-unwrap (`!`) — immer `guard let` / `if let` / `??`
- Async/Await fuer alle asynchronen Operationen
- `@MainActor` auf alle ViewModels
- Jede interne Methode mit `///` Dokumentationskommentar
- Jeden View mit `#Preview` Block + realistischen Mock-Daten — nie leerer Preview

---

## 4. Dateistruktur (49 Swift-Dateien)

```
ActivityTracker2/
├── App/
│   ├── ActivityTracker2App.swift
│   ├── ContentView.swift
│   ├── AppConstants.swift
│   └── Extensions.swift
├── Model/
│   ├── Activity.swift
│   ├── Location.swift
│   ├── Category.swift
│   ├── UserSettings.swift          ← HomeLocation, Subscription, Sprache, Präferenzen
│   ├── AppError.swift
│   ├── SubscriptionStatus.swift
│   └── AnalyticsEvent.swift
├── ViewModel/
│   ├── ActivityViewModel.swift
│   ├── MapViewModel.swift
│   ├── FilterViewModel.swift
│   ├── AddActivityViewModel.swift   ← steuert alle 3 Add-Screens
│   ├── StatsViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── PlusViewModel.swift
├── View/
│   ├── Screens/
│   │   ├── MapScreen.swift
│   │   ├── ListScreen.swift
│   │   ├── StatsScreen.swift
│   │   ├── PlusScreen.swift
│   │   ├── Add/
│   │   │   ├── AddActivityCategoryScreen.swift   ← Step 1: Kategorie
│   │   │   ├── AddActivityLocationScreen.swift   ← Step 2: Ort
│   │   │   └── AddActivityTextScreen.swift       ← Step 3: Titel & Text
│   │   ├── ActivityDetailScreen.swift
│   │   ├── EditActivityScreen.swift
│   │   ├── OnboardingScreen.swift
│   │   ├── LocationPermissionDeniedScreen.swift  ← Sackgassen-Screen
│   │   └── ActivityBottomSheet.swift
│   └── Components/
│       ├── ActivityRowView.swift
│       ├── ActivityCardView.swift
│       ├── CategoryPickerGrid.swift
│       ├── CategoryChipBar.swift
│       ├── ActivityMapAnnotation.swift
│       ├── MiniMapView.swift
│       ├── FilterStatusBanner.swift
│       ├── EmptyStateView.swift
│       ├── FloatingPlusButton.swift
│       ├── StatsSummaryCard.swift
│       ├── PlusBadge.swift
│       └── CategoryIconView.swift
└── Manager/
    ├── LocationManager.swift
    ├── GeocodeManager.swift
    ├── AnalyticsManager.swift
    ├── StoreKitManager.swift
    ├── HapticManager.swift
    └── LanguageManager.swift       ← Sprachauswahl DE/EN + erweiterbar
```

---

## 5. Datenmodell

### Activity (@Model)
- **Pflichtfelder:** `id: UUID`, `categoryId: String`, `date: Date`, `createdAt: Date`
- **`title: String?`** — OPTIONAL. Computed Property `displayTitle: String` liefert Fallback auf Kategoriename
- **`text: String?`** — OPTIONAL. Langer Freitext / Tagebucheintrag (mehrzeilig, kein Limit im MVP)
- **`note: String?`** — ENTFÄLLT — ersetzt durch `text`
- **`isFavorite: Bool`** optional
- **Kein lat/lng direkt** — Activity hat `var location: Location?` (Relation zum Location-Model)
- Preview-Helper: `Activity.preview`, `Activity.samples: [Activity]`

### Location (@Model) — separates Model
- **Pflichtfelder:** `id: UUID`, `latitude: Double`, `longitude: Double`
- **Optional:** `city: String?`, `region: String?`, `country: String?`
- **Inverse Relation:** `var activities: [Activity]`
- **Computed:** `coordinate: CLLocationCoordinate2D`
- **100m-Regel:** Beim Speichern einer neuen Activity prüft `AddActivityViewModel` ob eine Location <100m existiert. Falls ja → bestehende Location verwenden. Falls nein → neue Location anlegen. NICHT auf der Map berechnen.

### UserSettings (@AppStorage — kein SwiftData)
- Gespeichert via `@AppStorage` (UserDefaults) — kein SwiftData, kein iCloud im MVP
- **homeLatitude: Double?** — Zuhause-Koordinate (Latitude)
- **homeLongitude: Double?** — Zuhause-Koordinate (Longitude)
- **homeLocationName: String?** — Anzeigename, z.B. "München, Maxvorstadt"
- **subscriptionStatus: SubscriptionStatus** — free / plus (aus StoreKit verifiziert)
- **selectedLanguage: String** — "system" / "de" / "en"
- **hasCompletedOnboarding: Bool**
- **hasSeenPaywall: Bool** — fuer Paywall-Timing-Logik
- **activitiesCreatedCount: Int** — fuer Paywall-Trigger (nicht aus SwiftData zählen)
- **Wichtig:** UserSettings ist eine `@Observable` Klasse, wird in `ActivityTracker2App` erstellt und per `.environment()` injiziert — alle Views greifen per `@Environment` darauf zu

### Category (Struct — kein SwiftData)
- `id: String`, `nameDe: String`, `nameEn: String`, `iconName: String`, `colorHex: String`
- `Category.mvpCategories` (~30), `Category.plusCategories` (~70)
- Nur `categoryId: String` wird in Activity gespeichert — keine SwiftData-Relation

---

## 6. Monetarisierung

- **Free-Limit:** `100` Aktivitäten (`AppConstants.freeActivityLimit = 100`)
- **Plus MVP:** Einmalzahlung, exakt **8,99 EUR** — kein Abo
- **Plus 2.0:** Abo **3,99 EUR/Monat** — Fokus auf iCloud Sync. **Kein** Foto-Upload, **kein** AI-Recap in Plus 2.0
- **Feature-Gate:** immer via `SubscriptionStatus.isPremium` — nie hardcodierte Bools

### Paywall
- Trigger: 100 Aktivitäten erreicht, Plus-Kategorie gewählt, Plus-Tab geöffnet
- Nicht beim Start, nicht vor erster Aktivität
- Copy: "Mach dein Journal unbegrenzt." / "Einmal kaufen. Für immer behalten."

---

## 7. UI-Verhalten (kritische Details)

### Map
- Startscreen = immer Map, keine Ausnahmen
- **Kein Clustering** — Pins die <100m voneinander liegen teilen dieselbe Location (via Location-Model)
- Kein dynamisches Resizing der Pins
- Dominant-Category-Logik: Kategorie mit meisten Activities an Location = Pin-Icon
- CategoryChipBar oben, ein FilterButton rechts oben, FloatingPlusButton unten rechts

### Bottom Sheet (3 Detents)
```swift
presentationDetents([.fraction(0.15), .fraction(0.5), .fraction(1.0)])
```
- `0.15` = schmaler Streifen am unteren Rand — immer sichtbar nach Pin-Tap
- `0.5` = Standard, halbe Bildschirmhöhe — Listenansicht der Aktivitäten am Pin
- `1.0` = Vollbild = entspricht dem Listen-Screen (Map verschwindet)
- Wenn Filter aktiv und Pin getappt: Bottom Sheet zeigt nur Aktivitäten dieser Kategorie — aktiver Pin UND aktive Aktivität in der Liste sind hervorgehoben
- Scrollen in der Liste (0.5) führt die Map-Pins nach (aktiver Pin wechselt mit Scroll-Position)

### Filter
- **CategoryChipBar:** Single-Category-Filter, Chips sortiert nach Anzahl absteigend
- **Ein FilterButton** (rechts oben) → öffnet einfaches Kategorie-Auswahl-Sheet (Single-Category)
- **Kein Advanced Filter, kein Multi-Category, kein Zeitraum-Filter im MVP**
- Filter global: gilt für Map UND Liste synchron
- StatusBanner wenn aktiv: "Gefiltert: Wandern ✕"

### Swipe-Gesten in Liste UND Bottom Sheet
- **Swipe links:** zeigt Aktivitäten der nächsten Kategorie (aufsteigend nach Anzahl) — ChipBar wird nachgeführt; am Ende → "Alle" Aktivitäten
- **Swipe rechts:** zeigt Aktivitäten der nächsten Kategorie (absteigend nach Anzahl) — ChipBar wird nachgeführt
- Swipe ersetzt die angezeigte Liste komplett mit der neuen Kategorie

### Add Activity — 3-Screen-Flow
**Screen 1 — Kategorie wählen:**
- Vollbild-Grid mit Kategorie-Icons (CategoryPickerGrid)
- Tap auf Kategorie → weiter zu Screen 2

**Screen 2 — Ort wählen:**
- Autofill: aktuelle GPS-Position, Reverse Geocoding liefert Ortsvorschlag
- Suchmaske für manuellen Ort
- Sonderfall Kategorie "Tagebuch / Journal": fragt nach gespeicherter Zuhause-Koordinate — falls vorhanden wird diese direkt vorausgefüllt, User landet sofort auf Screen 3

**Screen 3 — Titel & Text:**
- Erste Zeile: `title` — fett (`font: .headline`), Cursor autofokussiert
- Nach Enter / Return: Cursor springt automatisch in nächste Zeile → `text` (normaler Font, mehrzeilig)
- Datum/Zeit: Default = jetzt, manuelle Änderung via separatem DatePicker-Sheet
- Save-Button: speichert Activity + löst Reverse Geocoding + 100m Location-Test aus

---

## 8. Datenschutz (non-negotiable)

- Kein Background Location, nie `requestAlwaysAuthorization()`
- Keine Benutzerkonten — anonym (lokale UUID)
- Keine personenbezogenen Analytics-Daten
- Kein Third-Party-Tracking-SDK
- Local-First, kein automatischer Cloud-Upload

---

## 9. Onboarding

- 3 Screens: App-Wert (mit Bild/Illustration) → Privacy → Location Permission
- TabView mit `.page` Style, "Weiter" + "Überspringen"
- `hasCompletedOnboarding` in `@AppStorage`
- **Location abgelehnt → Sackgassen-Screen:** "Remember funktioniert nur mit GPS-Ortsangabe" — User muss Berechtigung in Einstellungen aktivieren. Kein Weiterkommen ohne GPS.
- Alle Texte via `Localizable.xcstrings` — vollständig in DE + EN
- **Sprachauswahl im Onboarding:** User kann zwischen Deutsch und Englisch wählen — Auswahl wird gespeichert und überschreibt System-Sprache falls gewünscht
- **Architektur-Anforderung:** Lokalisierungsstruktur muss von Anfang an so aufgebaut sein, dass eine dritte Sprache (z.B. Französisch, Spanisch) ohne Refactoring hinzugefügt werden kann — String Catalog (`Localizable.xcstrings`) als einzige Quelle der Wahrheit

---

## 10. Internationalisierung (non-negotiable)

### Unterstützte Sprachen
- **Launch:** Deutsch (DE) + Englisch (EN) — beide vollständig, kein Platzhalter
- **Vorbereitet für:** beliebige weitere Sprachen ohne Code-Änderung (nur neue xcstrings-Einträge)

### Technische Umsetzung
- **Einzige String-Quelle:** `Localizable.xcstrings` (Xcode String Catalog) — nie `.strings` Dateien
- **Im Swift-Code:** ausschliesslich `String(localized: "key")` oder `LocalizedStringKey` in SwiftUI
- **Kein** `NSLocalizedString()` — veraltet
- **Kein** hardcodierter Text in Views — jeder sichtbare String hat einen Schlüssel im Catalog

### LanguageManager (neuer Manager — Batch 3)
```swift
// Manager/LanguageManager.swift
@Observable class LanguageManager {
    // Speichert User-Sprachwahl (überschreibt System-Sprache)
    @AppStorage("selectedLanguage") var selectedLanguage: String = "system"
    // "system" = iOS-Systemsprache, "de" = Deutsch, "en" = Englisch
    var supportedLanguages: [String] = ["system", "de", "en"]
}
```
- Sprachauswahl im Onboarding (Screen 1) und in den Settings
- Auswahl wird in `@AppStorage` gespeichert und beim App-Start angewendet

### Schlüssel-Konvention im String Catalog
```
// Format: bereich.unterbereich.beschreibung
"map.empty.title"          = "No activities yet"        / "Noch keine Aktivitäten"
"activity.add.button"      = "Add Activity"              / "Aktivität hinzufügen"
"onboarding.screen1.title" = "Your life on the map"     / "Dein Leben auf der Karte"
"filter.all"               = "All"                      / "Alle"
"plus.cta.purchase"        = "Buy once. Keep forever."  / "Einmal kaufen. Für immer behalten."
```

### Erweiterung auf dritte Sprache (Beispiel Französisch)
Nur drei Schritte nötig — kein Swift-Code muss geändert werden:
1. `Localizable.xcstrings` → neue Sprache "fr" hinzufügen
2. Alle Keys mit französischen Werten befüllen
3. `LanguageManager.supportedLanguages` um `"fr"` ergänzen

---

## 11. Analytics-Events (Pflicht)

| Event | Trigger |
|---|---|
| `appOpened` | App startet |
| `onboardingCompleted` | Onboarding fertig |
| `activitySaved(categoryId:city:)` | Activity gespeichert |
| `activityDeleted(categoryId:)` | Activity gelöscht |
| `mapPinTapped` | Pin getappt |
| `filterActivated(categoryId:)` | Filter gesetzt |
| `filterReset` | Filter zurückgesetzt |
| `paywallViewed(source:)` | Paywall angezeigt |
| `purchaseSuccess(productId:)` | Kauf erfolgreich |
| `statsOpened` | Stats-Tab geöffnet |

---

## 11. NIEMALS

- `ObservableObject` / `@Published`
- Force-Unwrap (`!`)
- `NavigationView` (deprecated)
- CoreData
- Backend-Calls / URLSession fuer Sync
- `requestAlwaysAuthorization()` — GPS nur "While Using App"
- SPM-Pakete ohne explizite Anfrage
- Leere `#Preview` ohne Mock-Daten
- `title` als Pflichtfeld — es ist `String?`
- `note` als Feldname — das Feld heisst `text: String?`
- lat/lng direkt in Activity — immer ueber Location-Model
- Zeitraum-Filter oder Multi-Category-Filter — nicht im MVP
- Zwei FilterButtons — nur einer
- Swipe-to-Delete in der Liste — Swipe wechselt Kategorie, nicht loescht
- GPS-Verweigerung ignorieren — ohne GPS kein Weiterkommen (Sackgassen-Screen)
- UserSettings in SwiftData speichern — ausschliesslich @AppStorage / UserDefaults
- HomeLocation in Activity hardcodieren — immer aus UserSettings.homeLatitude/homeLongitude lesen
- `NSLocalizedString()` verwenden — nur `String(localized:)` (modern, iOS 15+)
- Strings direkt in `.strings` Dateien — ausschliesslich `Localizable.xcstrings` (String Catalog)
- Sprach-Logik in Views — Sprachsteuerung nur via `LanguageManager`
