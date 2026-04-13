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
        city: String? = nil,
        region: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
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

    /// Bester verfügbarer Anzeigename: Stadt → Region → Land → Fallback.
    var displayName: String {
        city ?? region ?? country ?? String(localized: "location.unknown", defaultValue: "Unbekannt")
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
}
