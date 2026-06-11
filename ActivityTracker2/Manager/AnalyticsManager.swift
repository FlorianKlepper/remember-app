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

    /// Trackt Aktivitäts-Meilensteine (2 / 5 / 10 / 25 / 50 / 100).
    /// Wird nach jedem `activitySaved` mit dem aktuellen Gesamtcount aufgerufen.
    /// - Parameter count: Aktuelle Anzahl gespeicherter Aktivitäten.
    func trackActivityMilestone(count: Int) {
        let milestones = [2, 5, 10, 25, 50, 100]
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

    // MARK: First-Time Events

    /// Trackt den ersten Tap auf den Add-Button — einmalig pro Install.
    func trackFirstAddTapped() {
        let key = "hasTrackedFirstAddTap"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        PostHogSDK.shared.capture(
            "first_add_tapped",
            properties: [
                "days_since_install":    daysSinceInstall(),
                "minutes_since_install": minutesSinceInstall(),
                "time_bucket":           timeBucket()
            ])
    }

    /// Trackt die erste Listenansicht — einmalig pro Install.
    func trackFirstListViewed() {
        let key = "hasTrackedFirstListView"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        PostHogSDK.shared.capture(
            "first_list_viewed",
            properties: [
                "days_since_install":    daysSinceInstall(),
                "minutes_since_install": minutesSinceInstall(),
                "time_bucket":           timeBucket()
            ])
    }

    /// Trackt den ersten Aufruf des Plus Screens — einmalig pro Install.
    func trackFirstPlusScreenViewed() {
        let key = "hasTrackedFirstPlusScreen"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        PostHogSDK.shared.capture(
            "first_plus_screen_viewed",
            properties: [
                "days_since_install":    daysSinceInstall(),
                "minutes_since_install": minutesSinceInstall(),
                "time_bucket":           timeBucket()
            ])
    }

    /// Trackt den ersten Aufruf des Stats Screens — einmalig pro Install.
    func trackFirstStatsViewed() {
        let key = "hasTrackedFirstStatsView"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        PostHogSDK.shared.capture(
            "first_stats_viewed",
            properties: [
                "days_since_install":    daysSinceInstall(),
                "minutes_since_install": minutesSinceInstall(),
                "time_bucket":           timeBucket()
            ])
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

    /// Anzahl Minuten seit dem Install-Datum.
    private func minutesSinceInstall() -> Int {
        let installDate = UserDefaults.standard.object(forKey: "installDate") as? Date ?? Date()
        return Int(Date().timeIntervalSince(installDate) / 60)
    }

    /// Zeitbucket seit Install — für gruppierte Auswertung in PostHog.
    private func timeBucket() -> String {
        let minutes = minutesSinceInstall()
        switch minutes {
        case 0..<2:           return "0-2min"
        case 2..<5:           return "2-5min"
        case 5..<15:          return "5-15min"
        case 15..<60:         return "15-60min"
        case 60..<(60*24):    return "1-24h"
        case (60*24)..<(60*24*3): return "1-3days"
        default:              return "3days+"
        }
    }
}
