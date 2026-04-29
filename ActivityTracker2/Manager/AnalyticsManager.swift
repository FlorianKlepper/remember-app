// AnalyticsManager.swift
// ActivityTracker2 — Remember
// Analytics-Tracking via PostHog

import Foundation
import PostHog

// MARK: - AnalyticsManager

/// Zentraler Analytics-Manager der App — sendet Events via PostHog.
/// Im DEBUG-Modus werden Events zusätzlich auf der Konsole geloggt.
@Observable
final class AnalyticsManager {

    // MARK: Init

    init() {}

    // MARK: Tracking

    /// Tracked ein Analytics-Event via PostHog.
    /// Fire-and-forget — PostHog puffert und sendet intern asynchron.
    /// - Parameter event: Das zu trackende Event aus `AnalyticsEvent`.
    func track(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event)")
        #endif

        switch event {

        // MARK: App-Lifecycle

        case .appOpened:
            PostHogSDK.shared.capture("app_opened")

        // MARK: Onboarding

        case .onboardingCompleted:
            PostHogSDK.shared.capture("onboarding_completed")

        case .onboardingSkipped:
            PostHogSDK.shared.capture("onboarding_skipped")

        // MARK: Activity CRUD

        case .activitySaved(let categoryId, let city):
            PostHogSDK.shared.capture(
                "activity_saved",
                properties: [
                    "categoryId": categoryId,
                    "city": city ?? "unknown"
                ])

        case .activityDeleted(let categoryId):
            PostHogSDK.shared.capture(
                "activity_deleted",
                properties: [
                    "categoryId": categoryId
                ])

        case .activityEdited:
            PostHogSDK.shared.capture("activity_edited")

        // MARK: Filter

        case .filterActivated(let categoryId):
            PostHogSDK.shared.capture(
                "filter_activated",
                properties: [
                    "categoryId": categoryId
                ])

        case .filterReset:
            PostHogSDK.shared.capture("filter_reset")

        // MARK: Map

        case .mapPinTapped:
            PostHogSDK.shared.capture("map_pin_tapped")

        // MARK: Stats

        case .statsOpened:
            PostHogSDK.shared.capture("stats_opened")

        // MARK: Monetarisierung

        case .paywallViewed(let source):
            PostHogSDK.shared.capture(
                "paywall_viewed",
                properties: [
                    "source": source
                ])

        case .purchaseSuccess(let productId):
            PostHogSDK.shared.capture(
                "purchase_success",
                properties: [
                    "productId": productId
                ])

        case .purchaseFailed:
            PostHogSDK.shared.capture("purchase_failed")

        // MARK: Plus

        case .plusScreenViewed(let source):
            PostHogSDK.shared.capture(
                "plus_screen_viewed",
                properties: [
                    "source": source
                ])
        }
    }
}
