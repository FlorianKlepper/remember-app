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
        case .appOpened:
            TelemetryDeck.signal("app.opened")

        case .onboardingCompleted:
            TelemetryDeck.signal("onboarding.completed")

        case .activityCreated(let categoryId):
            TelemetryDeck.signal("activity.created",
                                 parameters: ["categoryId": categoryId])

        case .activityDeleted:
            TelemetryDeck.signal("activity.deleted")

        case .activityEdited:
            TelemetryDeck.signal("activity.edited")

        case .filterApplied(let categoryId):
            TelemetryDeck.signal("filter.applied",
                                 parameters: ["categoryId": categoryId])

        case .filterCleared:
            TelemetryDeck.signal("filter.cleared")

        case .pinTapped:
            TelemetryDeck.signal("map.pin_tapped")

        case .plusScreenViewed:
            TelemetryDeck.signal("plus.screen_viewed")

        case .plusPurchased:
            TelemetryDeck.signal("plus.purchased")
        }
    }
}
