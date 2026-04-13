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
            // Leitet an den Completion-Handler-Wrapper weiter, um die Deprecation-Warning
            // des async-Wrappers von CLGeocoder (deprecated in iOS 26) zu isolieren.
            // TODO: Auf neue MapKit-Geocoding-API migrieren, sobald die iOS-26-
            // Replacement-API stabil und dokumentiert ist.
            placemarks = try await performReverseGeocode(location: location)
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

    /// Isoliert den `CLGeocoder`-Completion-Handler-Call.
    /// Die Completion-Handler-Variante ist in iOS 26 nicht vom selben Deprecation-
    /// Warning betroffen wie der async-Wrapper — dadurch bleibt die Warning auf
    /// diese private Methode beschränkt und verunreinigt nicht den öffentlichen API.
    ///
    /// Sobald eine stabile MapKit-Alternative existiert, wird nur diese Methode
    /// ausgetauscht — kein Refactoring der restlichen GeocodeManager-Logik nötig.
    @available(iOS, deprecated: 26, message: "Auf MapKit-Geocoding-API migrieren sobald stabil")
    func performReverseGeocode(location: CLLocation) async throws -> [CLPlacemark] {
        try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: placemarks ?? [])
                }
            }
        }
    }
}
