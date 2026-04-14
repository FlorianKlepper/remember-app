// GeocodeManager.swift
// ActivityTracker2 — Remember
// Reverse Geocoding via CLGeocoder mit internem Koordinaten-Cache

import Foundation
import CoreLocation

// MARK: - GeocodeManager

/// Führt Reverse Geocoding via `CLGeocoder` durch.
/// Cached Ergebnisse per Cache-Key (lat/lng auf 3 Dezimalstellen gerundet),
/// um redundante Netzwerkaufrufe für nahe beieinander liegende Koordinaten zu vermeiden.
@Observable
final class GeocodeManager {

    // MARK: Nested Types

    /// Ergebnis eines Reverse Geocoding-Vorgangs.
    struct GeocodeResult {
        /// Stadtname, z.B. "München".
        let city: String?
        /// Bundesland oder Region, z.B. "Bayern".
        let region: String?
        /// Ländercode, z.B. "DE".
        let country: String?
    }

    // MARK: Private Properties

    /// Cache: Cache-Key (gerundete Koordinaten-String) → `GeocodeResult`.
    private var cache: [String: GeocodeResult] = [:]

    // MARK: Init

    init() {}
}

// MARK: - Öffentliche Methoden

extension GeocodeManager {

    /// Ermittelt Adressinformationen für eine Koordinate via Reverse Geocoding.
    /// Bei Cache-Treffer wird `completion` sync
    /// hron auf dem Main Thread aufgerufen.
    /// Bei Cache-Miss startet Geocoding im Hintergrund — `completion` kommt auf dem Main Thread an.
    /// - Parameters:
    ///   - coordinate: Die aufzulösende GPS-Koordinate.
    ///   - completion: Callback mit `GeocodeResult` (alle Felder optional).
    func geocode(
        _ coordinate: CLLocationCoordinate2D,
        completion: @escaping (GeocodeResult) -> Void
    ) {
        let key = cacheKey(for: coordinate)

        // Cache Hit — synchron zurückgeben
            if let cached = cache[key] {
            completion(cached)
            return
        }

        // Cache Miss — Geocoding im Hintergrund
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let p = placemarks?.first
            let result = GeocodeResult(
                city:    p?.locality,
                region:  p?.administrativeArea,
                country: p?.isoCountryCode
            )
            DispatchQueue.main.async {
                self?.cache[key] = result
                completion(result)
            }
        }
    }
}

// MARK: - Private Helpers

private extension GeocodeManager {

    /// Erzeugt einen Cache-Schlüssel aus einer Koordinate.
    /// Lat/Lng werden auf 3 Dezimalstellen gerundet (~110 m Genauigkeit).
    func cacheKey(for coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.3f_%.3f", coordinate.latitude, coordinate.longitude)
    }
}
