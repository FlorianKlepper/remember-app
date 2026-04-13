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
                defaultValue: "Ortszugriff verweigert. Bitte aktiviere den Zugriff in den Einstellungen."
            )
        case .locationUnavailable:
            return String(
                localized: "error.location.unavailable.description",
                defaultValue: "Standort ist aktuell nicht verfügbar. Bitte versuche es später erneut."
            )
        case .saveFailed:
            return String(
                localized: "error.save.failed.description",
                defaultValue: "Die Aktivität konnte nicht gespeichert werden. Bitte versuche es erneut."
            )
        case .geocodingFailed:
            return String(
                localized: "error.geocoding.failed.description",
                defaultValue: "Der Ort konnte nicht ermittelt werden. Bitte wähle ihn manuell."
            )
        case .storeKitError(let underlying):
            return String(
                localized: "error.storekit.description",
                defaultValue: "Kauf fehlgeschlagen: \(underlying.localizedDescription)"
            )
        case .homeLocationNotSet:
            return String(
                localized: "error.home.location.not.set.description",
                defaultValue: "Kein Heimatort gespeichert. Bitte lege einen Heimatort in den Einstellungen fest."
            )
        }
    }

    /// Optionaler Hinweistext mit möglicher Lösung.
    var recoverySuggestion: String? {
        switch self {
        case .locationDenied:
            return String(
                localized: "error.location.denied.recovery",
                defaultValue: "Öffne Einstellungen → Datenschutz → Ortungsdienste → Remember."
            )
        case .locationUnavailable:
            return String(
                localized: "error.location.unavailable.recovery",
                defaultValue: "Überprüfe deine Netzwerkverbindung oder deaktiviere den Flugmodus."
            )
        case .homeLocationNotSet:
            return String(
                localized: "error.home.location.not.set.recovery",
                defaultValue: "Gehe zu Einstellungen und tippe auf 'Heimatort festlegen'."
            )
        default:
            return nil
        }
    }
}
