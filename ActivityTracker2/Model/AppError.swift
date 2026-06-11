// AppError.swift
// ActivityTracker2 — Remember
// App-weite Fehlertypen mit lokalisierten Beschreibungen

import Foundation

// MARK: - AppError

/// Alle bekannten Fehlerzustände der App.
/// Konform zu `LocalizedError` — Fehlertexte über `Localizable.xcstrings` lokalisiert.
enum AppError: LocalizedError {

    // MARK: Cases

    /// GPS-Berechtigung vom User verweigert.
    case locationDenied

    /// GPS-Hardware oder -Dienste nicht verfügbar (z.B. Flugmodus, älteres Gerät).
    case locationUnavailable

    /// SwiftData-Speicheroperation fehlgeschlagen.
    case saveFailed

    /// Reverse Geocoding konnte keine Adresse für die Koordinate ermitteln.
    case geocodingFailed

    /// StoreKit-Fehler mit zugehörigem Swift-Error.
    case storeKitError(Error)

    /// Aktion erfordert eine gespeicherte Heimat-Location, die noch nicht gesetzt wurde.
    case homeLocationNotSet

    // MARK: LocalizedError

    /// Kurze, nutzerfreundliche Fehlerbeschreibung.
    var errorDescription: String? {
        switch self {
        case .locationDenied:
            return String(
                localized: "error.location.denied.description",
                defaultValue: "Location access denied. Please enable access in Settings."
            )
        case .locationUnavailable:
            return String(
                localized: "error.location.unavailable.description",
                defaultValue: "Location is currently unavailable. Please try again later."
            )
        case .saveFailed:
            return String(
                localized: "error.save.failed.description",
                defaultValue: "The activity could not be saved. Please try again."
            )
        case .geocodingFailed:
            return String(
                localized: "error.geocoding.failed.description",
                defaultValue: "The location could not be determined. Please select it manually."
            )
        case .storeKitError(let underlying):
            return String(
                localized: "error.storekit.description",
                defaultValue: "Purchase failed: \(underlying.localizedDescription)"
            )
        case .homeLocationNotSet:
            return String(
                localized: "error.home.location.not.set.description",
                defaultValue: "No home location saved. Please set a home location in Settings."
            )
        }
    }

    /// Optionaler Hinweistext mit möglicher Lösung.
    var recoverySuggestion: String? {
        switch self {
        case .locationDenied:
            return String(
                localized: "error.location.denied.recovery",
                defaultValue: "Open Settings → Privacy → Location Services → Remember."
            )
        case .locationUnavailable:
            return String(
                localized: "error.location.unavailable.recovery",
                defaultValue: "Check your network connection or disable Airplane mode."
            )
        case .homeLocationNotSet:
            return String(
                localized: "error.home.location.not.set.recovery",
                defaultValue: "Go to Settings and tap 'Set home location'."
            )
        default:
            return nil
        }
    }
}
