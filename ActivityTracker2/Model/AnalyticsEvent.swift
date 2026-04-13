// AnalyticsEvent.swift
// ActivityTracker2 — Remember
// Typsicheres Enum aller Analytics-Events

import Foundation

// MARK: - AnalyticsEvent

/// Alle vom `AnalyticsManager` verfolgten Events.
/// Jeder Case liefert via `eventName` und `parameters` die Daten,
/// die an das Analytics-Backend übergeben werden.
enum AnalyticsEvent {

    // MARK: App-Lifecycle

    /// App wird gestartet oder in den Vordergrund gebracht.
    case appOpened

    /// User hat den Onboarding-Flow vollständig abgeschlossen.
    case onboardingCompleted

    // MARK: Activity CRUD

    /// Eine Activity wurde erfolgreich in SwiftData gespeichert.
    /// - Parameters:
    ///   - categoryId: ID der gewählten Kategorie.
    ///   - city: Optional: erkannter Stadtname via Reverse Geocoding.
    case activitySaved(categoryId: String, city: String?)

    /// Eine Activity wurde vom User gelöscht.
    /// - Parameter categoryId: ID der gelöschten Activity-Kategorie.
    case activityDeleted(categoryId: String)

    // MARK: Map

    /// User hat einen Map-Pin angetippt und das Bottom Sheet geöffnet.
    case mapPinTapped

    // MARK: Filter

    /// Ein Kategorie-Filter wurde aktiviert.
    /// - Parameter categoryId: ID der gefilterten Kategorie.
    case filterActivated(categoryId: String)

    /// Aktiver Filter wurde zurückgesetzt.
    case filterReset

    // MARK: Monetarisierung

    /// Paywall wurde dem User angezeigt.
    /// - Parameter source: Auslöser der Paywall (z.B. `"activity_limit"`, `"plus_tab"`, `"plus_category"`).
    case paywallViewed(source: String)

    /// StoreKit-Kauf erfolgreich abgeschlossen.
    /// - Parameter productId: StoreKit-Produkt-ID des gekauften Produkts.
    case purchaseSuccess(productId: String)

    // MARK: Stats

    /// User hat den Stats-Tab geöffnet.
    case statsOpened
}

// MARK: - Event Metadata

extension AnalyticsEvent {

    /// Snake-case Event-Name für das Analytics-Backend.
    var eventName: String {
        switch self {
        case .appOpened:             return "app_opened"
        case .onboardingCompleted:   return "onboarding_completed"
        case .activitySaved:         return "activity_saved"
        case .activityDeleted:       return "activity_deleted"
        case .mapPinTapped:          return "map_pin_tapped"
        case .filterActivated:       return "filter_activated"
        case .filterReset:           return "filter_reset"
        case .paywallViewed:         return "paywall_viewed"
        case .purchaseSuccess:       return "purchase_success"
        case .statsOpened:           return "stats_opened"
        }
    }

    /// Zusätzliche Parameter als `[String: String]` Dictionary.
    /// Events ohne Parameter liefern ein leeres Dictionary zurück.
    var parameters: [String: String] {
        switch self {

        case .appOpened,
             .onboardingCompleted,
             .mapPinTapped,
             .filterReset,
             .statsOpened:
            return [:]

        case .activitySaved(let categoryId, let city):
            var params: [String: String] = ["category_id": categoryId]
            if let city {
                params["city"] = city
            }
            return params

        case .activityDeleted(let categoryId):
            return ["category_id": categoryId]

        case .filterActivated(let categoryId):
            return ["category_id": categoryId]

        case .paywallViewed(let source):
            return ["source": source]

        case .purchaseSuccess(let productId):
            return ["product_id": productId]
        }
    }
}
