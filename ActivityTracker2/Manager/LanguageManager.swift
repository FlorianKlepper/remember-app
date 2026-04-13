// LanguageManager.swift
// ActivityTracker2 — Remember
// Sprachauswahl DE/EN — überschreibt iOS-Systemsprache via UserDefaults

import Foundation
import SwiftUI

// MARK: - LanguageManager

/// Verwaltet die vom User gewählte App-Sprache.
/// `"system"` bedeutet: iOS-Systemsprache übernehmen.
/// Sprachauswahl wird via `@AppStorage` in UserDefaults persistiert und beim App-Start angewendet.
/// Neue Sprachen können ohne Code-Änderung ergänzt werden — nur `supportedLanguages` und
/// `Localizable.xcstrings` müssen aktualisiert werden.
@Observable
final class LanguageManager {

    // MARK: Properties

    /// Aktuell gespeicherte Sprachauswahl.
    /// Mögliche Werte: `"system"`, `"de"`, `"en"` (erweiterbar).
    @ObservationIgnored
    @AppStorage("selectedLanguage") var selectedLanguage: String = "system"

    /// Liste aller unterstützten Sprachcodes inkl. System-Option.
    let supportedLanguages: [String] = ["system", "de", "en"]

    // MARK: Init

    init() {}
}

// MARK: - Computed Properties

extension LanguageManager {

    /// Effektiver ISO-639-1-Sprachcode für UI-Logik (z.B. Category.localizedName).
    /// `"system"` wird zur Systemsprache aufgelöst — Fallback auf `"en"`.
    var currentLanguageCode: String {
        guard selectedLanguage == "system" else {
            return selectedLanguage
        }
        return Locale.current.language.languageCode?.identifier ?? "en"
    }

    /// Lokalisierbarer Anzeigename für einen Sprachcode — für Settings-UI.
    /// - Parameter code: Sprachcode (`"system"`, `"de"`, `"en"`).
    func displayName(for code: String) -> String {
        switch code {
        case "system":
            return String(localized: "language.system", defaultValue: "Systemsprache")
        case "de":
            return String(localized: "language.de", defaultValue: "Deutsch")
        case "en":
            return String(localized: "language.en", defaultValue: "English")
        default:
            return code.uppercased()
        }
    }
}

// MARK: - Methoden

extension LanguageManager {

    /// Wendet eine Sprachauswahl an und persistiert sie.
    /// Bei `"system"`: entfernt den `AppleLanguages`-Override aus UserDefaults.
    /// Bei `"de"` / `"en"`: setzt `AppleLanguages` auf den gewählten Code.
    ///
    /// > Wichtig: Eine App-Neustart ist für vollständige Lokalisierungsänderung erforderlich.
    /// > In-App-Texte über `String(localized:)` und `LocalizedStringKey` aktualisieren sich
    /// > beim nächsten View-Rebuild automatisch, wenn `currentLanguageCode` sich ändert.
    func applyLanguage(_ code: String) {
        selectedLanguage = code

        if code == "system" {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([code], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
}
