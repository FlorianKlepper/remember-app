// LanguageManager.swift
// ActivityTracker2 — Remember
// Sprachcode für Kategorie-Namen — folgt automatisch der iOS-Systemsprache

import Foundation

// MARK: - LanguageManager

/// Liefert den aktuellen ISO-639-1-Sprachcode basierend auf der iOS-Systemsprache.
/// Wird für Kategorie-Namen (DE/EN) in Views verwendet.
/// Kein manueller Sprachwechsel — die App folgt der Systemsprache.
@Observable
final class LanguageManager {

    // MARK: Init

    init() {}

    // MARK: Computed Properties

    /// Effektiver ISO-639-1-Sprachcode — direkt von der iOS-Systemsprache.
    /// Fallback auf `"de"` wenn die Systemsprache nicht erkannt wird.
    var currentLanguageCode: String {
        Locale.current.language.languageCode?.identifier ?? "de"
    }
}
