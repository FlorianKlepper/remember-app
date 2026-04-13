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

    /// Mehrere Beispiel-Activities für Listen-Previews.
    static var samples: [Activity] {
        let munich = Location(
            latitude: 48.1351, longitude: 11.5820,
            city: "München", region: "Bayern", country: "Deutschland"
        )
        let venice = Location(
            latitude: 45.4408, longitude: 12.3155,
            city: "Venedig", region: "Venetien", country: "Italien"
        )
        let berlin = Location(
            latitude: 52.5200, longitude: 13.4050,
            city: "Berlin", region: "Berlin", country: "Deutschland"
        )

        return [
            Activity(
                categoryId: "hiking",
                date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
                title: "Wanderung am Tegernsee",
                text: "Traumwetter, klare Sicht. Der Weg war perfekt.",
                isFavorite: true,
                location: munich
            ),
            Activity(
                categoryId: "restaurant",
                date: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
                title: "Cicchetti Bar in Venedig",
                text: "Kleine Weinbar versteckt in einer Seitengasse. Baccalà mantecato war ausgezeichnet.",
                isFavorite: false,
                location: venice
            ),
            Activity(
                categoryId: "concert",
                date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now,
                title: nil,
                text: "Philharmonie Berlin — Mahler Sinfonie Nr. 9. Unvergesslich.",
                isFavorite: true,
                location: berlin
            ),
            Activity(
                categoryId: "cafe",
                date: Calendar.current.date(byAdding: .day, value: -10, to: .now) ?? .now,
                title: "Frühstück im Café Luitpold",
                text: nil,
                isFavorite: false,
                location: munich
            )
        ]
    }
}
