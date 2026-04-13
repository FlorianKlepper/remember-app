// SubscriptionStatus.swift
// ActivityTracker2 — Remember
// Abo- und Kaufstatus des Users

import Foundation

// MARK: - SubscriptionStatus

/// Repräsentiert den aktuellen Kaufstatus des Users.
/// `RawRepresentable<String>` ermöglicht direkte Kompatibilität mit `@AppStorage`.
enum SubscriptionStatus: String, Codable, CaseIterable {

    /// Kostenloser Plan — Aktivitäten-Limit aktiv.
    case free = "free"

    /// Plus-Einmalkauf — unbegrenzte Aktivitäten und alle Kategorien.
    case plus = "plus"
}

// MARK: - Computed Properties

extension SubscriptionStatus {

    /// `true` wenn der User den Plus-Einmalkauf abgeschlossen hat.
    var isPremium: Bool {
        self == .plus
    }

    /// Maximale Anzahl erlaubter Aktivitäten.
    /// Free: `AppConstants.freeActivityLimit` — Plus: unbegrenzt (`Int.max`).
    var activitiesLimit: Int {
        switch self {
        case .free: return AppConstants.freeActivityLimit
        case .plus: return Int.max
        }
    }

    /// Lokalisierbarer Anzeigename des Plans.
    var displayName: String {
        switch self {
        case .free:
            return String(localized: "subscription.free.name", defaultValue: "Free")
        case .plus:
            return String(localized: "subscription.plus.name", defaultValue: "Plus")
        }
    }
}
