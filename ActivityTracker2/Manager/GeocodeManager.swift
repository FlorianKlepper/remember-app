// GeocodeManager.swift
// ActivityTracker2 — Remember
// Reverse Geocoding via CLGeocoder mit internem Koordinaten-Cache

import Foundation
import CoreLocation

// MARK: - GeocodeResult

/// Ergebnis eines Reverse Geocoding-Vorgangs.
/// `Sendable`, da nur value-type Felder enthält und über Actor-Grenzen übertragen wird.
struct GeocodeResult: Sendable {
    /// Stadtname, z.B. "München".
    let city: String?
    /// Bundesland oder Region, z.B. "Bayern".
    let region: String?
    /// Ländername, z.B. "Deutschland".
    let country: String?
}

// MARK: - GeocodeManager

/// Führt Reverse Geocoding via `CLGeocoder` durch.
/// Cached Ergebnisse per Cache-Key (lat/lng auf 3 Dezimalstellen gerundet),
/// um redundante Netzwerkaufrufe für nahe beieinander liegende Koordinaten zu vermeiden.
@Observable
final class GeocodeManager {

    // MARK: Private Properties

    private let geocoder = CLGeocoder()

    /// Cache: Cache-Key (gerundete Koordinaten-String) → `GeocodeResult`.
    private var cache: [String: GeocodeResult] = [:]

    // MARK: Init

    init() {}
}

// MARK: - Öffentliche Methoden

extension GeocodeManager {

    /// Ermittelt Adressinformationen für eine Koordinate via Reverse Geocoding.
    /// Gibt ein gecachtes Ergebnis zurück, wenn die Koordinate bereits aufgelöst wurde.
    /// - Parameter coordinate: Die aufzulösende GPS-Koordinate.
    /// - Throws: `AppError.geocodingFailed` bei fehlgeschlagenem Geocoding.
    /// - Returns: `GeocodeResult` mit Stadt, Region und Land (alle optional).
    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async throws -> GeocodeResult {
        let key = cacheKey(for: coordinate)

        if let cached = cache[key] {
            return cached
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let placemarks: [CLPlacemark]
        do {
            placemarks = try await geocoder.reverseGeocodeLocation(location)
        } catch {
            throw AppError.geocodingFailed
        }

        guard let placemark = placemarks.first else {
            throw AppError.geocodingFailed
        }

        let result = GeocodeResult(
            city:    placemark.locality,
            region:  placemark.administrativeArea,
            country: placemark.country
        )

        cache[key] = result
        return result
    }
}

// MARK: - Private Helpers

private extension GeocodeManager {

    /// Erzeugt einen Cache-Schlüssel aus einer Koordinate.
    /// Lat/Lng werden auf 3 Dezimalstellen gerundet (~110 m Genauigkeit).
    func cacheKey(for coordinate: CLLocationCoordinate2D) -> String {
        let lat = (coordinate.latitude  * 1_000).rounded() / 1_000
        let lng = (coordinate.longitude * 1_000).rounded() / 1_000
        return "\(lat),\(lng)"
    }
}
