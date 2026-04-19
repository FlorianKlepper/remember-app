// AnalyticsEvent.swift
// ActivityTracker2 — Remember
// Typsicheres Enum aller Analytics-Events

import Foundation

// MARK: - AnalyticsEvent

/// Alle vom `AnalyticsManager` verfolgten Events.
enum AnalyticsEvent {

    // MARK: App-Lifecycle

    /// App wird gestartet oder in den Vordergrund gebracht.
    case appOpened

    // MARK: Onboarding

    /// User hat den Onboarding-Flow vollständig abgeschlossen.
    case onboardingCompleted

    /// User hat auf "Überspringen" getippt und ist zur Location-Permission-Seite gesprungen.
    case onboardingSkipped

    // MARK: Activity CRUD

    /// Eine Activity wurde erfolgreich gespeichert.
    /// - Parameters:
    ///   - categoryId: ID der gewählten Kategorie.
    ///   - city: Erkannter Stadtname oder `nil` wenn kein Reverse Geocoding verfügbar.
    case activitySaved(categoryId: String, city: String?)

    /// Eine Activity wurde gelöscht.
    /// - Parameter categoryId: ID der Kategorie der gelöschten Activity.
    case activityDeleted(categoryId: String)

    /// Eine Activity wurde bearbeitet.
    case activityEdited

    // MARK: Filter

    /// Ein Kategorie-Filter wurde aktiviert.
    /// - Parameter categoryId: ID der gefilterten Kategorie.
    case filterActivated(categoryId: String)

    /// Aktiver Filter wurde zurückgesetzt.
    case filterReset

    // MARK: Map

    /// User hat einen Map-Pin angetippt.
    case mapPinTapped

    // MARK: Stats

    /// Stats-Tab wurde geöffnet.
    case statsOpened

    // MARK: Monetarisierung

    /// Paywall wurde angezeigt.
    /// - Parameter source: Auslöser der Paywall, z.B. "plus_tab", "activity_limit", "category_locked".
    case paywallViewed(source: String)

    /// Plus wurde erfolgreich gekauft.
    /// - Parameter productId: StoreKit-Produkt-ID des gekauften Produkts.
    case purchaseSuccess(productId: String)

    /// Kauf ist fehlgeschlagen (abgebrochen oder Fehler).
    case purchaseFailed
}
