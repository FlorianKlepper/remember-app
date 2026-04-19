// AnalyticsManager.swift
// ActivityTracker2 — Remember
// Analytics-Tracking via TelemetryDeck

import Foundation
import TelemetryDeck

// MARK: - AnalyticsManager

/// Zentraler Analytics-Manager der App — sendet Events via TelemetryDeck.
/// Im DEBUG-Modus werden Events zusätzlich auf der Konsole geloggt.
@Observable
final class AnalyticsManager {

    // MARK: Init

    init() {}

    // MARK: Tracking

    /// Tracked ein Analytics-Event via TelemetryDeck.
    /// Fire-and-forget — TelemetryDeck puffert und sendet intern asynchron.
    /// - Parameter event: Das zu trackende Event aus `AnalyticsEvent`.
    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event)")
        #endif

        switch event {

        // MARK: App-Lifecycle

        case .appOpened:
            TelemetryDeck.signal("app.opened")

        // MARK: Onboarding

        case .onboardingCompleted:
            TelemetryDeck.signal("onboarding.completed")

        case .onboardingSkipped:
            TelemetryDeck.signal("onboarding.skipped")

        // MARK: Activity CRUD

        case .activitySaved(let categoryId, let city):
            var params: [String: String] = ["categoryId": categoryId]
            if let city { params["city"] = city }
            TelemetryDeck.signal("activity.saved", parameters: params)

        case .activityDeleted(let categoryId):
            TelemetryDeck.signal("activity.deleted",
                                 parameters: ["categoryId": categoryId])

        case .activityEdited:
            TelemetryDeck.signal("activity.edited")

        // MARK: Filter

        case .filterActivated(let categoryId):
            TelemetryDeck.signal("filter.activated",
                                 parameters: ["categoryId": categoryId])

        case .filterReset:
            TelemetryDeck.signal("filter.reset")

        // MARK: Map

        case .mapPinTapped:
            TelemetryDeck.signal("map.pin_tapped")

        // MARK: Stats

        case .statsOpened:
            TelemetryDeck.signal("stats.opened")

        // MARK: Monetarisierung

        case .paywallViewed(let source):
            TelemetryDeck.signal("paywall.viewed",
                                 parameters: ["source": source])

        case .purchaseSuccess(let productId):
            TelemetryDeck.signal("purchase.success",
                                 parameters: ["productId": productId])

        case .purchaseFailed:
            TelemetryDeck.signal("purchase.failed")
        }
    }
}
