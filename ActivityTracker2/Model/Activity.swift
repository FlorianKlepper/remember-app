// Activity.swift
// ActivityTracker2 — Remember
// SwiftData-Modell für eine einzelne Aktivität / einen Tagebucheintrag

import Foundation
import SwiftData

// MARK: - Activity

/// Zentrale SwiftData-Entität, die einen Erlebniseintrag repräsentiert.
/// Jede Activity ist einer Kategorie (`categoryId`) und optional einem `Location`-Objekt zugeordnet.
@Model
final class Activity {

    // MARK: Pflichtfelder

    /// Eindeutige ID der Activity.
    var id: UUID

    /// Referenz auf die zugehörige Kategorie (nur ID, kein SwiftData-Relation).
    var categoryId: String

    /// Vom User gewähltes Datum des Erlebnisses.
    var date: Date

    /// Zeitstempel der Erstellung in der App.
    var createdAt: Date

    // MARK: Optionale Felder

    /// Kurzer Titel der Activity (max. `AppConstants.maxTitleLength` Zeichen). Darf leer sein.
    var title: String?

    /// Langer Freitext / Tagebucheintrag (max. `AppConstants.maxTextLength` Zeichen). Darf leer sein.
    var text: String?

    /// Gibt an, ob die Activity als Favorit markiert ist.
    var isFavorite: Bool

    // MARK: Relation

    /// Verknüpfter Ort. Wird nach dem Speichern asynchron via Reverse Geocoding befüllt.
    var location: Location?

    // MARK: Init

    /// Erstellt eine neue Activity mit den angegebenen Werten.
    init(
        id: UUID = UUID(),
        categoryId: String,
        date: Date = .now,
        createdAt: Date = .now,
        title: String? = nil,
        text: String? = nil,
        isFavorite: Bool = false,
        location: Location? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.date = date
        self.createdAt = createdAt
        self.title = title
        self.text = text
        self.isFavorite = isFavorite
        self.location = location
    }
}

// MARK: - Computed Properties

extension Activity {

    /// Anzeigetitel der Activity. Gibt `title` zurück, falls gesetzt und nicht leer.
    /// Fällt auf den lokalisierten Kategorienamen zurück; falls Kategorie unbekannt auf "Aktivität".
    var displayTitle: String {
        if let title, !title.isBlank {
            return title
        }
        let allCategories = Category.mvpCategories + Category.plusCategories
        guard let category = allCategories.first(where: { $0.id == categoryId }) else {
            return String(localized: "activity.fallback.title", defaultValue: "Aktivität")
        }
        let langCode = Locale.current.language.languageCode?.identifier ?? "en"
        return langCode == "de" ? category.nameDe : category.nameEn
    }

    /// Datum der Activity als formatierter String, z.B. "6. Feb 2026".
    var formattedDate: String {
        date.formattedActivityDate
    }

    /// Tag als String, z.B. "14".
    var dayString: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    /// Monat als Kurzform, z.B. "Apr".
    var monthString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        f.locale = Locale.current
        return f.string(from: date)
    }

    /// Jahr als Int, z.B. 2026.
    var yearInt: Int {
        Calendar.current.component(.year, from: date)
    }

    /// `true` wenn die Activity mindestens einen nicht-leeren Titel oder Text besitzt.
    var hasContent: Bool {
        let hasTitle = title.map { !$0.isBlank } ?? false
        let hasText  = text.map  { !$0.isBlank } ?? false
        return hasTitle || hasText
    }
}

// MARK: - Preview Helpers

extension Activity {

    /// Einzelne Beispiel-Activity für Xcode-Previews.
    static var preview: Activity {
        Activity(
            categoryId: "hiking",
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            title: "Wanderung am Tegernsee",
            text: "Traumwetter, klare Sicht bis zu den Alpen. Der Weg von Bad Wiessee nach Kreuth war perfekt.",
            isFavorite: true,
            location: Location.preview
        )
    }

    /// Fünf Münchner Beispiel-Activities für Map- und Listen-Previews.
    /// Je eine Activity pro Location aus `Location.samples`, mit verschiedenen Kategorien.
    static var samples: [Activity] {
        let locations = Location.samples

        return [
            Activity(
                categoryId: "restaurant",
                date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
                title: "Abendessen am Marienplatz",
                text: "Schöner Abend mit Blick auf das Rathaus.",
                isFavorite: true,
                location: locations[0]   // Marienplatz
            ),
            Activity(
                categoryId: "hiking",
                date: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
                title: "Spaziergang im Englischen Garten",
                text: "Endlich mal wieder raus. Der Monopteros bei Sonnenuntergang ist unschlagbar.",
                isFavorite: false,
                location: locations[1]   // Englischer Garten
            ),
            Activity(
                categoryId: "shopping",
                date: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now,
                title: "Markttag am Viktualienmarkt",
                text: "Frischer Käse und Radieschen vom Stand gegenüber.",
                isFavorite: false,
                location: locations[2]   // Viktualienmarkt
            ),
            Activity(
                categoryId: "fitness",
                date: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
                title: nil,
                text: "5 km Runde um den Olympiasee. Perfektes Wetter.",
                isFavorite: true,
                location: locations[3]   // Olympiapark
            ),
            Activity(
                categoryId: "bar",
                date: Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now,
                title: "Abend im Hofbräuhaus",
                text: nil,
                isFavorite: false,
                location: locations[4]   // Hofbräuhaus
            ),
        ]
    }
}
