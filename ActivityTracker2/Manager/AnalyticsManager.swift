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

    // MARK: Milestones

    // MARK: Milestones

    /// Trackt Aktivitäts-Meilensteine (5 / 10 / 25 / 50 / 100).
    /// Wird nach jedem `activitySaved` mit dem aktuellen Gesamtcount aufgerufen.
    /// - Parameter count: Aktuelle Anzahl gespeicherter Aktivitäten.
    func trackActivityMilestone(count: Int) {
        let milestones = [5, 10, 25, 50, 100]
        guard milestones.contains(count) else { return }

        PostHogSDK.shared.capture(
            "activity_milestone",
            properties: [
                "milestone":          count,
                "days_since_install": daysSinceInstall()
            ])

        print("Milestone: \(count) activities after \(daysSinceInstall()) days")
    }

    /// Trackt einen erfolgreichen Plus-Kauf mit Kontext-Properties.
    /// - Parameter activityCount: Anzahl Aktivitäten zum Kaufzeitpunkt.
    func trackPlusPurchased(activityCount: Int) {
        PostHogSDK.shared.capture(
            "plus_purchased",
            properties: [
                "activity_count_at_purchase": activityCount,
                "days_since_install":         daysSinceInstall()
            ])

        print("Plus purchased: \(activityCount) activities, day \(daysSinceInstall())")
    }

    // MARK: Private

    /// Anzahl Tage seit dem Install-Datum.
    /// Liest `installDate` aus UserDefaults — falls nicht gesetzt, wird das Bundle-Erstellungsdatum
    /// als Proxy für das App Store Install-Datum verwendet. Fallback: heute (→ 0 Tage).
    private func daysSinceInstall() -> Int {
        if UserDefaults.standard.object(forKey: "installDate") == nil {
            if let bundleURL   = Bundle.main.bundleURL as URL?,
               let attrs       = try? FileManager.default.attributesOfItem(atPath: bundleURL.path),
               let creationDate = attrs[.creationDate] as? Date {
                UserDefaults.standard.set(creationDate, forKey: "installDate")
            } else {
                UserDefaults.standard.set(Date(), forKey: "installDate")
            }
        }

        let installDate = UserDefaults.standard.object(forKey: "installDate") as? Date ?? Date()
        return max(0, Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0)
    }
}
