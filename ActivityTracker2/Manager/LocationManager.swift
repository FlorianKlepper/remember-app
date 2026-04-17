// LocationManager.swift
// ActivityTracker2 — Remember
// Wrapper um CLLocationManager mit async/await-API

import Foundation
import CoreLocation

// MARK: - LocationManager

/// Verwaltet GPS-Zugriff und liefert die aktuelle Position.
/// Nur `requestWhenInUseAuthorization()` — niemals `requestAlwaysAuthorization()`.
/// Delegate-Callbacks werden `nonisolated` empfangen und zurück auf `@MainActor` dispatched.
@Observable
@MainActor
final class LocationManager: NSObject {

    // MARK: Öffentliche Properties

    /// Zuletzt bekannte GPS-Koordinate des Geräts.
    var currentLocation: CLLocationCoordinate2D?

    /// Aktueller Autorisierungsstatus der App.
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: Private Properties

    private let locationManager = CLLocationManager()

    /// Offene Continuation für `fetchCurrentLocation()` — nur eine gleichzeitig aktiv.
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    // MARK: Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
}

// MARK: - Öffentliche Methoden

extension LocationManager {

    /// Fragt die "While Using App"-Berechtigung an.
    /// Ruft niemals `requestAlwaysAuthorization()` auf.
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Startet kontinuierliche Standort-Updates — hält `currentLocation` aktuell.
    /// Muss beim App-Start aufgerufen werden, damit `currentLocation` befüllt ist.
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    /// Stoppt kontinuierliche Standort-Updates.
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    /// Liefert die aktuelle GPS-Position asynchron.
    /// - Throws: `AppError.locationDenied` bei fehlender Berechtigung,
    ///           `AppError.locationUnavailable` bei Hardware- oder Netzwerkfehler.
    /// - Returns: Die ermittelte `CLLocationCoordinate2D`.
    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            throw AppError.locationDenied
        }
        return try await withCheckedThrowingContinuation { continuation in
            // Bestehende Continuation abbrechen, falls vorhanden (Schutz vor Doppelaufruf)
            locationContinuation?.resume(throwing: AppError.locationUnavailable)
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    /// Neue Standortdaten empfangen — nonisolated, Dispatch zurück auf MainActor.
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        Task { @MainActor [weak self] in
            self?.currentLocation = coordinate
            self?.locationContinuation?.resume(returning: coordinate)
            self?.locationContinuation = nil
        }
    }

    /// Standortfehler empfangen — Continuation mit Fehler beenden.
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            self?.locationContinuation?.resume(throwing: AppError.locationUnavailable)
            self?.locationContinuation = nil
        }
    }

    /// Autorisierungsstatus hat sich geändert.
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            self?.authorizationStatus = status
        }
    }
}
