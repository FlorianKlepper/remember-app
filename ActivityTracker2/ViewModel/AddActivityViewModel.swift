// AddActivityViewModel.swift
// ActivityTracker2 — Remember
// Steuert den 3-Screen-Add-Flow: Kategorie → Ort → Titel & Text

import Foundation
import CoreLocation
import SwiftData

// MARK: - AddActivityViewModel

/// Verwaltet den vollständigen "Neue Aktivität"-Flow über 3 Screens.
/// Screen 0: Kategorie wählen
/// Screen 1: Ort wählen (GPS oder manuell)
/// Screen 2: Titel, Text und Datum eingeben
@Observable
@MainActor
final class AddActivityViewModel {

    // MARK: Flow-State

    /// Aktueller Screen-Index im Add-Flow. 0 = Kategorie, 1 = Ort, 2 = Titel & Text.
    var currentStep: Int = 0

    // MARK: Step 1 — Kategorie

    /// Vom User gewählte Kategorie-ID.
    var selectedCategoryId: String? = nil

    // MARK: Step 2 — Ort

    /// GPS-Koordinate des gewählten Orts.
    var pendingCoordinate: CLLocationCoordinate2D? = nil

    /// Menschenlesbarer Ortsname (z.B. aus Reverse Geocoding oder Suche).
    var pendingLocationName: String? = nil

    /// Stadt des gewählten Orts (z.B. aus MKLocalSearch-Ergebnis).
    var pendingCity: String? = nil

    /// Land des gewählten Orts (z.B. aus MKLocalSearch-Ergebnis).
    var pendingCountry: String? = nil

    // MARK: Step 3 — Titel & Text

    /// Kurztitel der Activity (optional).
    var title: String = ""

    /// Langer Freitext / Tagebucheintrag (optional).
    var text: String = ""

    /// Datum des Erlebnisses — Default: jetzt.
    var selectedDate: Date = .now

    /// Sterne-Bewertung: 0 = keine, 1–3 Sterne.
    var starRating: Int = 0

    // MARK: Loading

    /// Wird während SwiftData-Operationen auf `true` gesetzt.
    var isLoading: Bool = false

    // MARK: Sheet-Dismiss-Signal

    /// `true` nach erfolgreichem Speichern — löst das Schließen des Add-Sheets aus.
    /// Wird von `AddActivityCategoryScreen` beobachtet, das als Sheet-Root `dismiss()` aufruft.
    var isSaved: Bool = false

    // MARK: Navigation-Overrides

    /// `true` wenn der Location-Screen übersprungen werden soll (z.B. bei journal_home).
    var skipLocationScreen: Bool = false

    // MARK: Init

    init() {}
}

// MARK: - Computed Properties

extension AddActivityViewModel {

    /// `true` wenn die gewählte Kategorie Tagebuch- oder Journal-Charakter hat.
    var isJournalCategory: Bool {
        selectedCategoryId == "journal"        ||
        selectedCategoryId == "journal_home"   ||
        selectedCategoryId == "journal_travel" ||
        selectedCategoryId == "personal_note"
    }

    /// `true` wenn Step 2 (Ort) vollständig ist — Koordinate muss gesetzt sein.
    var isStep2Valid: Bool {
        pendingCoordinate != nil
    }

    /// `true` wenn Step 3 (Text) gespeichert werden kann — mind. Titel oder Text nicht leer.
    var isStep3Valid: Bool {
        !title.isBlank || !text.isBlank
    }
}

// MARK: - Location

extension AddActivityViewModel {

    /// Sucht eine bestehende Location innerhalb von `AppConstants.locationGroupingRadius` (100 m)
    /// oder erstellt eine neue Location, falls keine passende gefunden wird.
    ///
    /// Verhindert Pin-Proliferation: Activities am gleichen Ort teilen eine Location.
    ///
    /// - Parameters:
    ///   - coordinate: Ziel-Koordinate der neuen Activity.
    ///   - context: Aktiver SwiftData `ModelContext`.
    /// - Throws: `AppError.saveFailed` wenn das Fetching fehlschlägt.
    /// - Returns: Bestehende oder neu erstellte `Location`.
    func findOrCreateLocation(
        coordinate: CLLocationCoordinate2D,
        context: ModelContext
    ) async throws -> Location {
        let descriptor = FetchDescriptor<Location>()
        let existingLocations: [Location]
        do {
            existingLocations = try context.fetch(descriptor)
        } catch {
            throw AppError.saveFailed
        }

        if let nearby = existingLocations.first(where: {
            $0.coordinate.distance(to: coordinate) < AppConstants.locationGroupingRadius
        }) {
            return nearby
        }

        let newLocation = Location(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        context.insert(newLocation)
        return newLocation
    }

    /// Befüllt `pendingCoordinate` und `pendingLocationName` aus der gespeicherten
    /// Heimat-Location in `UserSettings`. Springt danach direkt zu Step 2 (Ort überbrückt).
    /// Wird für Journal- und Notiz-Kategorien aufgerufen.
    func useHomeLocation(from settings: UserSettings) {
        guard let coordinate = settings.homeCoordinate else { return }
        pendingCoordinate = coordinate
        pendingLocationName = settings.homeName
    }
}

// MARK: - Speichern

extension AddActivityViewModel {

    /// Speichert die neue Activity: erstellt oder findet die Location, legt die Activity an
    /// und delegiert an `ActivityViewModel.addActivity`.
    ///
    /// - Parameters:
    ///   - activityViewModel: Das zentrale ActivityViewModel für die tatsächliche Persistenz.
    ///   - context: Aktiver SwiftData `ModelContext`.
    /// - Throws: `AppError.locationUnavailable` wenn keine Koordinate gesetzt ist,
    ///           `AppError.saveFailed` bei Datenbankfehlern.
    func saveActivity(
        activityViewModel: ActivityViewModel,
        context: ModelContext
    ) async throws {
        guard let coordinate = pendingCoordinate,
              let categoryId = selectedCategoryId else {
            throw AppError.locationUnavailable
        }

        isLoading = true
        defer { isLoading = false }

        let location = try await findOrCreateLocation(coordinate: coordinate, context: context)

        // POI-Name, Stadt und Land aus Auswahl nachpflegen
        if let name = pendingLocationName, !name.isBlank {
            location.locationName = name
        }
        if location.city == nil, let city = pendingCity, !city.isBlank {
            location.city = city
        }
        if location.country == nil, let country = pendingCountry, !country.isBlank {
            location.country = country
        }

        try await activityViewModel.addActivity(
            title: title.isBlank ? nil : title,
            text:  text.isBlank  ? nil : text,
            categoryId: categoryId,
            location: location,
            date: selectedDate,
            starRating: starRating,
            context: context
        )
    }
}

// MARK: - Reset

extension AddActivityViewModel {

    /// Setzt alle Properties auf Ausgangszustand zurück.
    /// Aufruf nach erfolgreichem Speichern oder beim Schließen des Sheets.
    func reset() {
        currentStep = 0
        selectedCategoryId = nil
        pendingCoordinate = nil
        pendingLocationName = nil
        pendingCity = nil
        pendingCountry = nil
        title = ""
        text = ""
        selectedDate = .now
        starRating = 0
        isLoading = false
        isSaved = false
        skipLocationScreen = false
    }
}
