// Location.swift
// ActivityTracker2 — Remember
// SwiftData-Modell für einen geografischen Ort

import Foundation
import SwiftData
import CoreLocation

// MARK: - Location

/// Repräsentiert einen gespeicherten geografischen Ort.
/// Mehrere `Activity`-Einträge können dieselbe Location teilen, wenn sie
/// innerhalb von `AppConstants.locationGroupingRadius` (100 m) liegen.
@Model
final class Location {

    // MARK: Pflichtfelder

    /// Eindeutige ID der Location.
    var id: UUID

    /// Geografische Breite (WGS 84).
    var latitude: Double

    /// Geografische Länge (WGS 84).
    var longitude: Double

    // MARK: Optionale Felder (via Reverse Geocoding)

    /// POI-Name, z.B. "Pöllinger Hof" oder "Marienplatz".
    var locationName: String?

    /// Stadtname, z.B. "München".
    var city: String?

    /// Bundesland oder Region, z.B. "Bayern".
    var region: String?

    /// Ländername, z.B. "Deutschland".
    var country: String?

    // MARK: Inverse Relation

    /// Alle Activities, die dieser Location zugeordnet sind.
    @Relationship(deleteRule: .nullify, inverse: \Activity.location)
    var activities: [Activity] = []

    // MARK: Init

    /// Erstellt eine neue Location mit den angegebenen Koordinaten.
    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        locationName: String? = nil,
        city: String? = nil,
        region: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.city = city
        self.region = region
        self.country = country
    }
}

// MARK: - Computed Properties

extension Location {

    /// `CLLocationCoordinate2D` aus den gespeicherten Koordinaten.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Bester verfügbarer Anzeigename: POI-Name → Stadt → Region → Land → Fallback.
    var displayName: String {
        locationName ?? city ?? region ?? country ?? String(localized: "location.unknown", defaultValue: "Unbekannt")
    }
}

// MARK: - City Normalization

extension Location {

    /// Normalisiert einen Stadtnamen auf die kanonische deutsche Schreibweise.
    ///
    /// Deckt häufige englische und alternative Schreibweisen ab, die CLGeocoder
    /// je nach Gerätesprache zurückgeben kann.
    ///
    /// - Parameters:
    ///   - city: Rohwert aus Reverse Geocoding (z.B. "Munich").
    ///   - country: Ländername — kann zukünftig für länderspezifische Mappings genutzt werden.
    /// - Returns: Kanonischer Stadtname oder der Originalwert, wenn kein Mapping bekannt.
    static func normalizeCity(_ city: String?, country: String?) -> String? {
        guard let city else { return nil }

        let mappings: [String: String] = [
            // München
            "Munich": "München",
            "Muenchen": "München",
            "munich": "München",
            "münchen": "München",
            // Frankfurt
            "Frankfurt am Main": "Frankfurt",
            // Köln
            "Cologne": "Köln",
            "Koeln": "Köln",
            // Wien
            "Vienna": "Wien",
            "Vienne": "Wien",
            // Bereinigung Länderanhänge
            "Berlin, Germany": "Berlin",
            "Hamburg, Germany": "Hamburg",
        ]

        return mappings[city] ?? city
    }
}

// MARK: - Preview Helpers

extension Location {

    /// Beispiel-Location (München Stadtmitte) für Xcode-Previews.
    static var preview: Location {
        Location(
            latitude: 48.1351,
            longitude: 11.5820,
            city: "München",
            region: "Bayern",
            country: "Deutschland"
        )
    }

    /// Fünf realistische Münchner Locations für Map- und Listen-Previews.
    static var samples: [Location] {
        [
            Location(
                latitude: 48.1374, longitude: 11.5755,
                city: "Marienplatz", region: "Bayern", country: "Deutschland"
            ),
            Location(
                latitude: 48.1642, longitude: 11.6054,
                city: "Englischer Garten", region: "Bayern", country: "Deutschland"
            ),
            Location(
                latitude: 48.1351, longitude: 11.5761,
                city: "Viktualienmarkt", region: "Bayern", country: "Deutschland"
            ),
            Location(
                latitude: 48.1731, longitude: 11.5508,
                city: "Olympiapark", region: "Bayern", country: "Deutschland"
            ),
            Location(
                latitude: 48.1376, longitude: 11.5800,
                city: "Hofbräuhaus", region: "Bayern", country: "Deutschland"
            ),
        ]
    }
}
